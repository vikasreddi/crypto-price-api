class CreateCryptoPrices < ActiveRecord::Migration[8.1]
  def change
    create_table :crypto_prices do |t|
      t.string :symbol
      t.decimal :price_usd
      t.datetime :fetched_at

      t.timestamps
    end
  end
end
