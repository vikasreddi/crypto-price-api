class RefreshAllCryptoPricesJob < ApplicationJob
  queue_as :default

  def perform
    CryptoPrice.find_each(batch_size: 100) do |crypto|
      FetchCryptoPriceJob.perform_later(crypto.symbol)
    end
  end
end
