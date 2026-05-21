require "rails_helper"

RSpec.describe "Prices API", type: :request do
  before do
    Rails.cache.clear
  end

  describe "GET /prices/:symbol" do
    it "returns cached price for valid symbol" do
      CryptoPrice.create!(
        symbol: "btc",
        coingecko_id: "bitcoin",
        price_usd: 45000,
        status: :success
      )

      Rails.cache.write(
        "crypto_price_btc",
        {
          price: 50000,
          fetched_at: Time.current
        }
      )

      get "/prices/btc"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["symbol"]).to eq("btc")
      expect(body["price"]).to eq(50000)
      expect(body["source"]).to eq("cache")
    end

    it "returns database fallback when cache is missing" do
      CryptoPrice.create!(
        symbol: "eth",
        coingecko_id: "ethereum",
        price_usd: 2500,
        fetched_at: Time.current,
        status: :success
      )

      get "/prices/eth"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["symbol"]).to eq("eth")
      expect(body["price"].to_i).to eq(2500)
      expect(body["source"]).to eq("database_fallback")
    end

    it "returns bad request for unsupported symbol" do
      get "/prices/random"

      expect(response).to have_http_status(:bad_request)

      body = JSON.parse(response.body)

      expect(body["symbol"]).to eq("random")
      expect(body["error"]).to eq("Invalid or unsupported crypto symbol")
      expect(body["source"]).to eq("validation")
    end
  end
end
