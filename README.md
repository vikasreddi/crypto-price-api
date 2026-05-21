# Crypto Price API

A Ruby on Rails API that fetches cryptocurrency prices from CoinGecko, stores the latest known prices in MySQL, caches prices in Redis, and serves fallback prices when the external API or cache is unavailable.

---

## Problem Statement

Build a small Rails API that fetches cryptocurrency prices from a public API such as CoinGecko.

### Requirements

- `/prices/:symbol` should return cached price for a given crypto symbol.
- A background job should fetch cryptocurrency prices every minute and store them.
- If the external API fails, continue serving the last known price.
- Add unit tests for:
  - Job logic
  - Fallback logic
  - Caching behavior
- Document the project step by step.
- Push the project to a public GitHub repository.
- Test the API using Postman.

---

## Tech Stack

- Ruby on Rails 8
- MySQL
- Redis
- Sidekiq
- Whenever gem
- CoinGecko API
- RSpec
- Postman

---

## Features Implemented

- Rails API endpoint: `/prices/:symbol`
- CoinGecko API integration
- MySQL persistence for latest known price
- Redis caching for fast API response
- Sidekiq background job processing
- Whenever cron scheduler to run every minute
- Database fallback when Redis cache is missing
- Last known price serving when external API fails
- Failure tracking using enum status
- RSpec tests for job logic, caching behavior, fallback logic, and API response
- Postman testing support
- Step-by-step documentation

---

## High-Level Architecture

```text
                    +-------------------+
                    |   Client/Postman  |
                    +---------+---------+
                              |
                              v
                    GET /prices/:symbol
                              |
                              v
                    +-------------------+
                    | PricesController  |
                    +---------+---------+
                              |
                              v
                 +------------------------+
                 | PriceResponseService   |
                 +-----------+------------+
                             |
          +------------------+------------------+
          |                                     |
          v                                     v
+-------------------+                 +-------------------+
| Redis Cache       |                 | MySQL Database    |
| crypto_price_btc  |                 | crypto_prices     |
+-------------------+                 +-------------------+
          |                                     |
          v                                     v
Return cache response              Return DB fallback response


# Background Job Architecture

                 Cron Scheduler
              runs every 1 minute
                       |
                       v
        +-------------------------------+
        | RefreshAllCryptoPricesJob     |
        +---------------+---------------+
                        |
                        v
       Reads all configured currencies from DB
                        |
                        v
       Enqueues FetchCryptoPriceJob per currency
                        |
        +---------------+---------------+
        |               |               |
        v               v               v
 Fetch BTC Job     Fetch ETH Job    Fetch SOL Job
        |               |               |
        v               v               v
      CoinGecko external API call for price
                        |
                        v
              Update MySQL latest price
                        |
                        v
              Update Redis cache

# API Request Flow

User calls /prices/btc
        |
        v
PricesController receives symbol
        |
        v
PriceResponseService checks Redis cache
        |
        |-- If cache exists:
        |       return price from Redis with source = cache
        |
        |-- If cache is missing:
        |       check MySQL database
        |
        |-- If DB record exists:
        |       return last known price with source = database_fallback
        |
        |-- If DB record does not exist:
                return invalid/unsupported symbol error


# Background Refresh Flow

Whenever cron runs every minute
        |
        v
RefreshAllCryptoPricesJob.perform_later
        |
        v
Reads all crypto records from MySQL using find_each
        |
        v
For each crypto record, enqueue FetchCryptoPriceJob
        |
        v
FetchCryptoPriceJob calls CoinGecko using coingecko_id
        |
        v
If API succeeds:
        - update price_usd
        - update fetched_at
        - update last_success_at
        - set status = success
        - reset failure_count
        - clear error_message
        - write latest price to Redis cache

If API fails:
        - do not overwrite old price
        - set status = failed
        - update last_failed_at
        - increment failure_count
        - store error_message
        - API continues serving last known price from DB

# Folder Structure

app/
 ├── controllers/
 │    └── prices_controller.rb
 │
 ├── jobs/
 │    ├── fetch_crypto_price_job.rb
 │    └── refresh_all_crypto_prices_job.rb
 │
 ├── models/
 │    └── crypto_price.rb
 │
 ├── services/
 │    ├── coingecko_service.rb
 │    ├── crypto_price_cache_service.rb
 │    └── price_response_service.rb
 │
config/
 ├── schedule.rb
 ├── application.example.yml
 └── application.yml  # ignored from GitHub
 │
spec/
 ├── jobs/
 ├── services/
 └── requests/