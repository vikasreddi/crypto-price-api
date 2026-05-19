class AddTrackingFieldsToCryptoPrices < ActiveRecord::Migration[8.1]
  def change
    add_column :crypto_prices, :coingecko_id, :string
    add_column :crypto_prices, :status, :integer, default: 1, null: false
    add_column :crypto_prices, :last_success_at, :datetime
    add_column :crypto_prices, :last_failed_at, :datetime
    add_column :crypto_prices, :failure_count, :integer, default: 0, null: false
    add_column :crypto_prices, :error_message, :text

    add_index :crypto_prices, :symbol, unique: true
  end
end
