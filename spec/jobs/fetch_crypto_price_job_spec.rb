require 'rails_helper'

RSpec.describe FetchCryptoPriceJob, type: :job do
  describe '#perform' do
    it 'stores crypto price in database' do
      allow(CoingeckoService).to receive(:fetch_price).and_return(50000)

      described_class.perform_now('btc')

      crypto = CryptoPrice.last

      expect(crypto.symbol).to eq('btc')
      expect(crypto.price_usd.to_i).to eq(50000)
    end

    it 'writes data to cache' do
      allow(CoingeckoService).to receive(:fetch_price).and_return(50000)

      described_class.perform_now('btc')

      cached = Rails.cache.read('crypto_price_btc')

      expect(cached[:price]).to eq(50000)
    end

    it 'handles API failure gracefully' do
      allow(CoingeckoService).to receive(:fetch_price).and_raise(StandardError)

      expect {
        described_class.perform_now('btc')
      }.not_to raise_error
    end
  end
end
