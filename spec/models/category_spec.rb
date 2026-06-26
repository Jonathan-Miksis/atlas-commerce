require "rails_helper"

RSpec.describe Category, type: :model do
  describe "associations" do
    it { should have_many(:products).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:category) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:slug) }

    it "requires name to be at least 2 characters" do
      category = build(:category, name: "A")
      expect(category).not_to be_valid
      expect(category.errors[:name]).to be_present
    end

    it "requires name to be at most 100 characters" do
      category = build(:category, name: "A" * 101)
      expect(category).not_to be_valid
    end

    it "requires slug to match lowercase alphanumeric with hyphens" do
      category = build(:category, slug: "Invalid Slug!")
      expect(category).not_to be_valid
    end

    it "allows valid slugs" do
      category = build(:category, slug: "electronics-2024")
      expect(category).to be_valid
    end
  end

  describe "slug generation" do
    it "auto-generates a slug from name if blank" do
      category = create(:category, name: "Office Supplies", slug: nil)
      expect(category.slug).to eq("office-supplies")
    end

    it "uses provided slug if given" do
      category = create(:category, name: "Electronics", slug: "tech-gear")
      expect(category.slug).to eq("tech-gear")
    end

    it "does not overwrite an existing slug on update" do
      category = create(:category, name: "Electronics", slug: "tech-gear")
      category.update!(name: "Consumer Electronics")
      expect(category.slug).to eq("tech-gear")
    end

    it "generates unique slugs for similar names" do
      create(:category, name: "Electronics", slug: "electronics")
      category2 = build(:category, name: "Electronics Pro", slug: nil)
      category2.valid?
      expect(category2.slug).not_to eq("electronics")
    end
  end

  describe "#to_param" do
    it "returns the slug" do
      category = build(:category, slug: "electronics")
      expect(category.to_param).to eq("electronics")
    end
  end

  describe "dependent destroy" do
    it "destroys associated products when category is deleted" do
      category = create(:category)
      create_list(:product, 3, category: category)
      expect { category.destroy }.to change(Product, :count).by(-3)
    end

    it "does not affect other categories' products" do
      category1 = create(:category)
      category2 = create(:category)
      create_list(:product, 2, category: category1)
      create_list(:product, 2, category: category2)
      expect { category1.destroy }.not_to change { Product.where(category: category2).count }
    end
  end

  describe "scoping and querying" do
    it "can find a category by slug" do
      category = create(:category, slug: "office-supplies")
      expect(Category.find_by(slug: "office-supplies")).to eq(category)
    end

    it "returns nil for a non-existent slug" do
      expect(Category.find_by(slug: "does-not-exist")).to be_nil
    end
  end
end
