require "rails_helper"
require "active_job/test_helper"

RSpec.describe FetchCryptoPriceJob, type: :job do
  describe "#perform" do
    let!(:crypto_price) do
      CryptoPrice.create!(
        symbol: "btc",
        coingecko_id: "bitcoin",
        status: :success
      )
    end

    before do
      Rails.cache.clear
    end

    it "fetches price, updates database, and writes to cache" do
      allow(CoingeckoService).to receive(:fetch_price)
        .with("bitcoin")
        .and_return(50000)

      described_class.perform_now("btc")

      crypto_price.reload

      expect(crypto_price.price_usd.to_i).to eq(50000)
      expect(crypto_price.status).to eq("success")
      expect(crypto_price.failure_count).to eq(0)
      expect(crypto_price.last_success_at).to be_present
      expect(crypto_price.error_message).to be_nil

      cached_data = Rails.cache.read("crypto_price_btc")

      expect(cached_data[:price]).to eq(50000)
      expect(cached_data[:fetched_at]).to be_present
    end

    it "marks currency as failed when CoinGecko returns nil" do
      allow(CoingeckoService).to receive(:fetch_price)
        .with("bitcoin")
        .and_return(nil)

      described_class.perform_now("btc")

      crypto_price.reload

      expect(crypto_price.status).to eq("failed")
      expect(crypto_price.failure_count).to eq(1)
      expect(crypto_price.last_failed_at).to be_present
      expect(crypto_price.error_message).to eq("Price not received from CoinGecko")
    end

    it "does not overwrite old price when external API fails" do
      crypto_price.update!(
        price_usd: 45000,
        fetched_at: 10.minutes.ago,
        last_success_at: 10.minutes.ago
      )

      allow(CoingeckoService).to receive(:fetch_price)
        .with("bitcoin")
        .and_return(nil)

      described_class.perform_now("btc")

      crypto_price.reload

      expect(crypto_price.price_usd.to_i).to eq(45000)
      expect(crypto_price.status).to eq("failed")
    end

    it "skips unsupported symbol without calling CoinGecko" do
      allow(CoingeckoService).to receive(:fetch_price)

      described_class.perform_now("random")

      expect(CoingeckoService).not_to have_received(:fetch_price)
    end
  end
end
