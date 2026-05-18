class FetchCryptoPriceJob < ApplicationJob
  queue_as :default

  def perform(symbol)
    price = CoingeckoService.fetch_price(symbol)

    crypto = CryptoPrice.find_or_initialize_by(symbol: symbol)

    crypto.update!(
      price_usd: price,
      fetched_at: Time.current
    )

    Rails.cache.write(
      "crypto_price_#{symbol}",
      {
        price: price,
        fetched_at: Time.current
      },
      expires_in: 5.minutes
    )

  rescue StandardError => e
    Rails.logger.error("Failed to fetch #{symbol}: #{e.message}")
  end
end
