class PricesController < ApplicationController
  def show
    symbol = params[:symbol]

    cached_data = Rails.cache.read("crypto_price_#{symbol}")

    if cached_data
      render json: {
        symbol: symbol,
        price: cached_data[:price],
        fetched_at: cached_data[:fetched_at],
        source: "cache"
      }
      return
    end

    crypto_price = CryptoPrice.find_by(symbol: symbol)

    if crypto_price
      render json: {
        symbol: symbol,
        price: crypto_price.price_usd,
        fetched_at: crypto_price.fetched_at,
        source: "database_fallback"
      }
    else
      render json: {
        error: "Price not available"
      }, status: :not_found
    end
  end
end
