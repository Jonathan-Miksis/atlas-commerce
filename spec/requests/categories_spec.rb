require "rails_helper"

RSpec.describe "Api::V1::Categories", type: :request do
  let!(:electronics) { create(:category, name: "Electronics", slug: "electronics") }
  let!(:office)      { create(:category, name: "Office Supplies", slug: "office-supplies") }

  describe "GET /api/v1/categories" do
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

    it "returns categories in order" do
      get "/api/v1/categories"
      names = response.parsed_body.map { |c| c["name"] }
      expect(names).to eq(names.sort)
    end
  end

  describe "GET /api/v1/categories/:slug" do
    context "with a valid slug" do
      it "returns the category" do
        get "/api/v1/categories/electronics"
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["name"]).to eq("Electronics")
      end

      it "returns the category's products" do
        create_list(:product, 3, category: electronics)
        get "/api/v1/categories/electronics"
        expect(response.parsed_body["products"].length).to eq(3)
      end

      it "only returns active products" do
        create(:product, :active, category: electronics)
        create(:product, :inactive, category: electronics)
        get "/api/v1/categories/electronics"
        expect(response.parsed_body["products"].length).to eq(1)
      end
    end

    context "with an invalid slug" do
      it "returns 404" do
        get "/api/v1/categories/does-not-exist"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
