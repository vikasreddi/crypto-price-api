# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
currencies = [
  { symbol: "btc", coingecko_id: "bitcoin" },
  { symbol: "eth", coingecko_id: "ethereum" },
  { symbol: "sol", coingecko_id: "solana" },
  { symbol: "doge", coingecko_id: "dogecoin" }
]

currencies.each do |currency|
  CryptoPrice.find_or_create_by!(symbol: currency[:symbol]) do |crypto|
    crypto.coingecko_id = currency[:coingecko_id]
    crypto.status = :success
  end
end
