require "rails_helper"

RSpec.describe "Api::V1::Categories", type: :request do
  describe "GET /api/v1/categories" do
    before do
      create(:category, name: "Electronics", slug: "electronics")
      create(:category, name: "Office Supplies", slug: "office-supplies")
    end

    it "returns all categories" do
      get "/api/v1/categories"
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.length).to eq(2)
    end

    it "returns categories with correct fields" do
      get "/api/v1/categories"
      category = response.parsed_body.first
      expect(category.keys).to include("id", "name", "slug")
    end

    it "returns categories in alphabetical order" do
      get "/api/v1/categories"
      names = response.parsed_body.pluck("name")
      expect(names).to eq(names.sort)
    end
  end

  describe "GET /api/v1/categories/:slug" do
    before do
      create(:category, name: "Electronics", slug: "electronics")
    end

    it "returns the category" do
      get "/api/v1/categories/electronics"
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["name"]).to eq("Electronics")
    end

    it "returns the category's products" do
      electronics = Category.find_by(slug: "electronics")
      create_list(:product, 3, category: electronics)
      get "/api/v1/categories/electronics"
      expect(response.parsed_body["products"].length).to eq(3)
    end

    it "only returns active products" do
      electronics = Category.find_by(slug: "electronics")
      create(:product, category: electronics, active: true)
      create(:product, :inactive, category: electronics)
      get "/api/v1/categories/electronics"
      expect(response.parsed_body["products"].length).to eq(1)
    end

    it "returns 404 for an unknown slug" do
      get "/api/v1/categories/does-not-exist"
      expect(response).to have_http_status(:not_found)
    end
  end
end
