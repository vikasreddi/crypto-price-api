class CryptoPrice < ApplicationRecord
  enum :status, {
    failed: 0,
    success: 1
  }

  validates :symbol, presence: true, uniqueness: true
  validates :coingecko_id, presence: true
  validates :price_usd, numericality: true, allow_nil: true

  before_validation :normalize_symbol

  private

  def normalize_symbol
    self.symbol = symbol.to_s.downcase.strip
  end
end
