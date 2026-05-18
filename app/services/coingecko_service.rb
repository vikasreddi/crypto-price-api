class CoingeckoService
  include HTTParty

  BASE_URL = "https://api.coingecko.com/api/v3"

  SYMBOL_MAPPING = {
    "btc" => "bitcoin",
    "eth" => "ethereum"
  }

  def self.fetch_price(symbol)
    coin_id = SYMBOL_MAPPING[symbol]

    response = get(
      "#{BASE_URL}/simple/price",
      query: {
        ids: coin_id,
        vs_currencies: "usd"
      },
      headers: {
        "x-cg-demo-api-key" => "CG-u5ZvsvVpyous4vka8YZcQcAr"
      }
    )

    response[coin_id]["usd"]
  end
end
