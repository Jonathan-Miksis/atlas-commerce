#!/usr/bin/env bash
set -e

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Atlas Commerce — Demo Environment Setup   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── 1. Ruby version ──────────────────────────────────────────────────────────
REQUIRED_RUBY="3.2.3"
CURRENT_RUBY=$(ruby --version 2>/dev/null | awk '{print $2}' || echo "none")

if [[ "$CURRENT_RUBY" != "$REQUIRED_RUBY" ]]; then
  echo "⚠️  Ruby $REQUIRED_RUBY required (you have: $CURRENT_RUBY)"
  echo ""
  echo "Install with rbenv:"
  echo "  brew install rbenv ruby-build     # if not installed"
  echo "  rbenv install $REQUIRED_RUBY"
  echo "  rbenv local $REQUIRED_RUBY"
  echo "  ruby --version                    # should show $REQUIRED_RUBY"
  echo ""
  echo "Or with rvm:"
  echo "  rvm install $REQUIRED_RUBY"
  echo "  rvm use $REQUIRED_RUBY"
  echo ""
  read -p "Continue anyway? (y/N) " -n 1 -r; echo
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# ── 2. Bundler ────────────────────────────────────────────────────────────────
echo "→ Installing gems..."
gem install bundler --no-document -q 2>/dev/null || true
bundle install

# ── 3. Database ───────────────────────────────────────────────────────────────
echo "→ Setting up database..."
bundle exec rails db:create db:migrate db:seed

# ── 4. Run the test suite (should be all green) ───────────────────────────────
echo ""
echo "→ Running test suite (should be all green)..."
bundle exec rspec --format progress
echo ""

# ── 5. Set up demo branches ──────────────────────────────────────────────────
echo "→ Setting up demo branches..."

# Make sure we're on main
git checkout main 2>/dev/null || git checkout -b main

# ── feature/add-bulk-pricing (the green PR) ───────────────────────────────────
git checkout -b feature/add-bulk-pricing 2>/dev/null || git checkout feature/add-bulk-pricing

# Add the bulk-pricing method to the Product model — this is correct code (PR passes)
cat >> app/models/product.rb << 'RUBY'

  def bulk_price(quantity)
    raise ArgumentError, "Quantity must be positive" unless quantity.positive?
    discount = case quantity
               when 1..9   then 0
               when 10..49 then 5
               when 50..99 then 10
               else 15
               end
    discounted_price(discount)
  end
RUBY

git add app/models/product.rb
git commit -m "feat: add bulk pricing tiers to Product model

Products now support quantity-based pricing:
- 1-9 units:  list price
- 10-49 units: 5% discount
- 50-99 units: 10% discount
- 100+ units:  15% discount

Closes #12"

git checkout main

# ── demo/failing-test (the red PR) ────────────────────────────────────────────
# This branch has a deliberate bug in the discount test — used for Beat 2
git checkout -b demo/failing-test 2>/dev/null || git checkout demo/failing-test

# Introduce a subtle bug: wrong expected value in discounted_price test
# The method returns 80.00 for a 20% discount on $100, but we assert 75.00
sed -i '' 's/expect(product.discounted_price(20)).to eq(80.00)/expect(product.discounted_price(20)).to eq(75.00)/' \
  spec/models/product_spec.rb 2>/dev/null || \
sed -i 's/expect(product.discounted_price(20)).to eq(80.00)/expect(product.discounted_price(20)).to eq(75.00)/' \
  spec/models/product_spec.rb

git add spec/models/product_spec.rb
git commit -m "feat: add 25% flash sale discount logic

Applying promotional pricing for Q4 flash sale.
Expected discount calculation updated for campaign."

git checkout main

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Setup complete! Here's what was created:                   ║"
echo "║                                                              ║"
echo "║  Branches:                                                   ║"
echo "║    main                  ← stable, all green                ║"
echo "║    feature/add-bulk-pricing ← green PR (Beat 1 & 3)        ║"
echo "║    demo/failing-test     ← red PR for Beat 2               ║"
echo "║                                                              ║"
echo "║  Next steps:                                                 ║"
echo "║    1. Push to GitHub (the script will do this for you)      ║"
echo "║    2. Enable branch protection on main (require CI checks)  ║"
echo "║    3. Create staging + production environments              ║"
echo "║    4. Add yourself as required reviewer on production       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
