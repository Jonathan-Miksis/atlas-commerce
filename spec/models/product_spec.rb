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
