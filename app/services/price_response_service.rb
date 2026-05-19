class PriceResponseService
  def initialize(symbol)
    @symbol = symbol.to_s.downcase.strip
  end

  def call
    cached_response || database_fallback_response || invalid_symbol_response
  end

  private

  attr_reader :symbol

  def cached_response
    cached_data = CryptoPriceCacheService.read(symbol)
    return nil unless cached_data.present?

    {
      status: :ok,
      body: {
        symbol: symbol,
        price: cached_data[:price],
        fetched_at: cached_data[:fetched_at],
        source: "cache"
      }
    }
  end

  def database_fallback_response
    crypto = CryptoPrice.find_by(symbol: symbol)
    return nil unless crypto.present?

    {
      status: :ok,
      body: {
        symbol: crypto.symbol,
        price: crypto.price_usd,
        fetched_at: crypto.fetched_at,
        source: "database_fallback"
      }
    }
  end

  def invalid_symbol_response
    {
      status: :bad_request,
      body: {
        symbol: symbol,
        error: "Invalid or unsupported crypto symbol",
        source: "validation"
      }
    }
  end
end
