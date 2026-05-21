require "rails_helper"

RSpec.describe PriceResponseService do
  describe "#call" do
    before do
      Rails.cache.clear
    end

    it "returns price from cache when cache is available" do
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

      result = described_class.new("btc").call

      expect(result[:status]).to eq(:ok)
      expect(result[:body][:symbol]).to eq("btc")
      expect(result[:body][:price]).to eq(50000)
      expect(result[:body][:source]).to eq("cache")
    end

    it "returns database fallback when cache is missing" do
      crypto_price = CryptoPrice.create!(
        symbol: "btc",
        coingecko_id: "bitcoin",
        price_usd: 45000,
        fetched_at: Time.current,
        status: :success,
        failure_count: 0
      )

      result = described_class.new("btc").call

      expect(result[:status]).to eq(:ok)
      expect(result[:body][:symbol]).to eq("btc")
      expect(result[:body][:price].to_i).to eq(45000)
      expect(result[:body][:source]).to eq("database_fallback")
    end

    it "returns validation error for unsupported symbol" do
      result = described_class.new("random").call

      expect(result[:status]).to eq(:bad_request)
      expect(result[:body][:symbol]).to eq("random")
      expect(result[:body][:error]).to eq("Invalid or unsupported crypto symbol")
      expect(result[:body][:source]).to eq("validation")
    end
  end
end
