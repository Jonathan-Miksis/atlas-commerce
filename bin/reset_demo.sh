#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# reset_demo.sh — resets the demo to a clean state for another practice run
# Usage: bash bin/reset_demo.sh
# Run from the root of the atlas-commerce repo
# ─────────────────────────────────────────────────────────────────────────────
set -e

GREEN_BRANCH="feature/add-bulk-pricing"
RED_BRANCH="demo/failing-test"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║      Atlas Commerce — Demo Reset             ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── 1. Sync main ─────────────────────────────────────────────────────────────
echo "→ Syncing main with GitHub..."
git checkout main
git fetch origin
git reset --hard origin/main

# ── 2. Delete old branches locally and remotely ──────────────────────────────
echo "→ Removing old demo branches..."
for branch in "$GREEN_BRANCH" "$RED_BRANCH"; do
  git branch -D "$branch" 2>/dev/null && echo "  deleted local: $branch" || echo "  no local branch: $branch"
  git push origin --delete "$branch" 2>/dev/null && echo "  deleted remote: $branch" || echo "  no remote branch: $branch"
done

# ── 3. Create demo/failing-test FIRST (RED — fails CI) ───────────────────────
echo ""
echo "→ Creating $RED_BRANCH..."
git checkout -b "$RED_BRANCH"

# Write spec with deliberate bug — asserts 75.00 instead of correct 80.00
cat > spec/models/product_spec.rb << 'SPEC'
require "rails_helper"

RSpec.describe Product, type: :model do
  describe "associations" do
    it { should belong_to(:category) }
  end

  describe "validations" do
    subject { build(:product) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:sku) }
    it { should validate_presence_of(:price) }
    it { should validate_uniqueness_of(:sku) }

    it "requires price to be greater than 0" do
      product = build(:product, price: 0)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("must be greater than 0")
    end

    it "requires stock to be >= 0" do
      product = build(:product, stock: -1)
      expect(product).not_to be_valid
    end

    it "requires SKU to be uppercase alphanumeric with hyphens" do
      product = build(:product, sku: "invalid sku!")
      expect(product).not_to be_valid
    end
  end

  describe "scopes" do
    let(:category) { create(:category) }

    before do
      create(:product, :featured, category: category, name: "Featured One")
      create(:product, category: category, name: "Regular One")
      create(:product, :inactive, category: category, name: "Inactive One")
      create(:product, :out_of_stock, category: category, name: "Out of Stock")
    end

    it "active scope returns only active products" do
      expect(Product.active.count).to eq(3)
      expect(Product.active.map(&:name)).not_to include("Inactive One")
    end

    it "featured scope returns only featured products" do
      expect(Product.featured.count).to eq(1)
      expect(Product.featured.first.name).to eq("Featured One")
    end

    it "in_stock scope returns products with stock > 0" do
      expect(Product.in_stock.count).to eq(3)
      expect(Product.in_stock.map(&:name)).not_to include("Out of Stock")
    end
  end

  describe "#in_stock?" do
    it "returns true when stock is greater than 0" do
      product = build(:product, stock: 5)
      expect(product.in_stock?).to be true
    end

    it "returns false when stock is 0" do
      product = build(:product, :out_of_stock)
      expect(product.in_stock?).to be false
    end
  end

  describe "#discounted_price" do
    let(:product) { build(:product, price: 100.00) }

    it "applies a percentage discount correctly" do
      expect(product.discounted_price(20)).to eq(75.00)
    end

    it "handles a 0% discount" do
      expect(product.discounted_price(0)).to eq(100.00)
    end

    it "handles a 100% discount" do
      expect(product.discounted_price(100)).to eq(0.00)
    end

    it "rounds to 2 decimal places" do
      product = build(:product, price: 9.99)
      expect(product.discounted_price(10)).to eq(8.99)
    end

    it "raises ArgumentError for invalid discount percentage" do
      expect { product.discounted_price(101) }.to raise_error(ArgumentError, /between 0 and 100/)
      expect { product.discounted_price(-1) }.to  raise_error(ArgumentError, /between 0 and 100/)
    end
  end
end
SPEC

git add spec/models/product_spec.rb
git commit -m "feat: update discount calculation for Q4 flash sale

Applying promotional pricing for Q4 flash sale campaign.
Updated expected discount calculation to reflect new rates."

git push origin "$RED_BRANCH"
echo "  ✓ $RED_BRANCH pushed"

# ── 4. Create feature/add-bulk-pricing LAST (GREEN — passes CI) ──────────────
echo ""
echo "→ Creating $GREEN_BRANCH..."
git checkout main
git checkout -b "$GREEN_BRANCH"

# Write the complete product.rb with bulk_price already included
cat > app/models/product.rb << 'RUBY'
class Product < ApplicationRecord
  belongs_to :category

  validates :name,  presence: true, length: { minimum: 2, maximum: 200 }
  validates :sku,   presence: true, uniqueness: true,
                    format: { with: /\A[A-Z0-9\-]+\z/, message: "must be uppercase letters, numbers, and hyphens only" }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  scope :active,      -> { where(active: true) }
  scope :featured,    -> { where(featured: true) }
  scope :in_stock,    -> { where("stock > 0") }
  scope :by_category, ->(category_id) { where(category_id: category_id) }

  def in_stock?
    stock > 0
  end

  def discounted_price(percent)
    raise ArgumentError, "Discount must be between 0 and 100" unless percent.between?(0, 100)

    (price * (1 - percent / 100.0)).round(2)
  end

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
end
RUBY

git add app/models/product.rb
git commit -m "feat: add bulk pricing tiers to Product model

Products now support quantity-based pricing:
- 1-9 units:   list price
- 10-49 units: 5% discount
- 50-99 units: 10% discount
- 100+ units:  15% discount

Closes #12"

git push origin "$GREEN_BRANCH"
echo "  ✓ $GREEN_BRANCH pushed"

# ── 5. Back to main ──────────────────────────────────────────────────────────
git checkout main

echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║  Reset complete! Ready for another practice run.                    ║"
echo "║                                                                      ║"
echo "║  Go to: github.com/Jonathan-Miksis/atlas-commerce                   ║"
echo "║                                                                      ║"
echo "║  Demo arc:                                                           ║"
echo "║    1. Open PR from demo/failing-test   → CI fails, merge blocked   ║"
echo "║    2. Close that PR (don't merge)                                   ║"
echo "║    3. Open PR from feature/add-bulk-pricing → CI passes            ║"
echo "║    4. Merge → staging auto-deploys                                  ║"
echo "║    5. Approve production deployment                                 ║"
echo "║    6. Actions tab → Run workflow button → show on-demand deploy     ║"
echo "║                                                                      ║"
echo "║  workflow_dispatch (Run workflow button):                            ║"
echo "║    Actions tab → CD → Run workflow → pick environment + reason      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
