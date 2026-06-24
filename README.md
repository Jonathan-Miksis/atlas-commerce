# Atlas Commerce API

[![CI](https://github.com/Jonathan-Miksis/atlas-commerce/actions/workflows/ci.yml/badge.svg)](https://github.com/Jonathan-Miksis/atlas-commerce/actions/workflows/ci.yml)

A B2B e-commerce platform API built with Ruby on Rails. Manages products, categories, and a product catalog for enterprise customers.

## Stack

- **Ruby** 3.2.3
- **Rails** 7.1 (API mode)
- **SQLite** (development & test)
- **RSpec** for testing
- **RuboCop** for linting

## Quick start

```bash
git clone https://github.com/Jonathan-Miksis/atlas-commerce.git
cd atlas-commerce

# Install Ruby 3.2.3 (if needed)
rbenv install 3.2.3
rbenv local 3.2.3

# Install dependencies
bundle install

# Set up the database
rails db:create db:migrate db:seed

# Run the server
rails s

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/api/v1/categories` | List all categories |
| GET | `/api/v1/categories/:slug` | Get category with products |
| GET | `/api/v1/products` | List active products |
| GET | `/api/v1/products/featured` | List featured products |
| GET | `/api/v1/products/:id` | Get a product |
| POST | `/api/v1/products` | Create a product |
| PATCH | `/api/v1/products/:id` | Update a product |
| DELETE | `/api/v1/products/:id` | Soft-delete a product |

## CI/CD

Every pull request runs three jobs in parallel:

- **Lint** — RuboCop style checks
- **Test** — RSpec full suite
- **Build** — Boot verification

Merging to `main` triggers automatic deployment to **staging**. Promotion to **production** requires a manual approval and creates a full audit trail.
