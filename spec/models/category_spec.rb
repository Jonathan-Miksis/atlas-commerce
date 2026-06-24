require "rails_helper"

RSpec.describe Category, type: :model do
  describe "associations" do
    it { should have_many(:products).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:category) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }

    it "requires name to be at least 2 characters" do
      category = build(:category, name: "A")
      expect(category).not_to be_valid
    end

    it "requires slug to be lowercase alphanumeric with hyphens" do
      category = build(:category, slug: "Invalid Slug!")
      expect(category).not_to be_valid
    end
  end

  describe "slug generation" do
    it "auto-generates a slug from name if blank" do
      category = create(:category, name: "Office Supplies", slug: nil)
      expect(category.slug).to eq("office-supplies")
    end

    it "uses provided slug if given" do
      category = create(:category, name: "Electronics", slug: "tech")
      expect(category.slug).to eq("tech")
    end
  end

  describe "#to_param" do
    it "returns the slug" do
      category = build(:category, slug: "electronics")
      expect(category.to_param).to eq("electronics")
    end
  end
end
