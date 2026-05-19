class CryptoPriceCacheService
  EXPIRY_TIME = 5.minutes

  def self.read(symbol)
    Rails.cache.read(cache_key(symbol))
  end

  def self.write(symbol, price, fetched_at)
    Rails.cache.write(
      cache_key(symbol),
      {
        price: price,
        fetched_at: fetched_at
      },
      expires_in: EXPIRY_TIME
    )
  end

  def self.cache_key(symbol)
    "crypto_price_#{symbol}"
  end
end
