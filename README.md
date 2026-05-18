# Crypto Price API

A Rails API application that fetches cryptocurrency prices from CoinGecko and caches them.

## Features

- Fetch cryptocurrency prices
- Background job updates every minute
- Redis caching
- MySQL persistence
- Fallback to last known price if API fails
- RSpec unit tests

## Technologies Used

- Ruby 3.3
- Rails 8 API
- MySQL
- Redis
- Sidekiq
- RSpec

## API Endpoint

GET /prices/:symbol

Example:

/prices/btc

Response:

```json
{
  "symbol": "btc",
  "price": 76959,
  "fetched_at": "2026-05-18T13:42:13.637Z",
  "source": "cache"
}
```

## Setup Instructions

### Clone Repository

```bash
git clone <repo_url>
cd crypto_price_api
```

### Install Dependencies

```bash
bundle install
```

### Database Setup

```bash
rails db:create
rails db:migrate
```

### Start Redis

```bash
redis-server
```

### Start Rails Server

```bash
rails s
```

### Run Sidekiq

```bash
bundle exec sidekiq
```

### Run Tests

```bash
bundle exec rspec
```

## Scheduler

Background jobs run every minute using Whenever + Cron.

## CoinGecko API

https://www.coingecko.com/

API Key used for development.