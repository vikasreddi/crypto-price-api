class FetchCryptoPriceJob < ApplicationJob
  queue_as :default

  def perform(symbol)
    symbol = symbol.to_s.downcase.strip

    crypto = CryptoPrice.find_by(symbol: symbol)

    unless crypto
      Rails.logger.warn("Skipping unsupported crypto symbol: #{symbol}")
      return
    end

    price = CoingeckoService.fetch_price(crypto.coingecko_id)

    if price.blank?
      mark_failure(crypto, "Price not received from CoinGecko")
      return
    end

    current_time = Time.current

    crypto.update!(
      price_usd: price,
      fetched_at: current_time,
      last_success_at: current_time,
      last_failed_at: nil,
      failure_count: 0,
      error_message: nil,
      status: :success
    )

    CryptoPriceCacheService.write(symbol, price, current_time)

    Rails.logger.info("Successfully updated #{symbol} price: #{price}")
  rescue StandardError => e
    crypto ||= CryptoPrice.find_by(symbol: symbol)

    mark_failure(crypto, e.message) if crypto

    Rails.logger.error("FetchCryptoPriceJob failed for #{symbol}: #{e.message}")
  end

  private

  def mark_failure(crypto, message)
    crypto.update!(
      last_failed_at: Time.current,
      failure_count: crypto.failure_count.to_i + 1,
      error_message: message,
      status: :failed
    )
  end
end
