require "rails_helper"
require "active_job/test_helper"

RSpec.describe RefreshAllCryptoPricesJob, type: :job do
  describe "#perform" do
    before do
      CryptoPrice.create!(symbol: "btc", coingecko_id: "bitcoin", status: :success)
      CryptoPrice.create!(symbol: "eth", coingecko_id: "ethereum", status: :success)

      allow(FetchCryptoPriceJob).to receive(:perform_later)
    end

    it "triggers individual fetch job for each crypto record" do
      described_class.perform_now

      expect(FetchCryptoPriceJob).to have_received(:perform_later).with("btc")
      expect(FetchCryptoPriceJob).to have_received(:perform_later).with("eth")
    end
  end
end
