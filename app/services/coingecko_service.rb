class CoingeckoService
  include HTTParty

  BASE_URL = "https://api.coingecko.com/api/v3"

  def self.fetch_price(coingecko_id)
    response = get(
      "#{BASE_URL}/simple/price",
      query: {
        ids: coingecko_id,
        vs_currencies: "usd"
      },
      headers: {
        "x-cg-demo-api-key" => ENV.fetch("COINGECKO_API_KEY")
      }
    )

    return nil unless response.success?

    response.dig(coingecko_id, "usd")
  rescue StandardError => e
    Rails.logger.error("CoinGecko API failed for #{coingecko_id}: #{e.message}")
    nil
  end
end
