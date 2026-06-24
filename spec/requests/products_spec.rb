require "rails_helper"

RSpec.describe "Api::V1::Products", type: :request do
  let(:category) { create(:category) }

  describe "GET /api/v1/products" do
    before do
      create_list(:product, 3, category: category)
      create(:product, :inactive, category: category)
    end

    it "returns HTTP 200" do
      get "/api/v1/products"
      expect(response).to have_http_status(:ok)
    end

    it "returns only active products" do
      get "/api/v1/products"
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
    end

    it "includes category information" do
      get "/api/v1/products"
      json = JSON.parse(response.body)
      expect(json.first).to have_key("category")
    end
  end

  describe "GET /api/v1/products/featured" do
    before do
      create(:product, category: category)
      create(:product, :featured, category: category, name: "Hero Product")
    end

    it "returns only featured products" do
      get "/api/v1/products/featured"
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first["name"]).to eq("Hero Product")
    end
  end

  describe "GET /api/v1/products/:id" do
    let(:product) { create(:product, category: category) }

    it "returns the product" do
      get "/api/v1/products/#{product.id}"
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(product.id)
      expect(json["sku"]).to eq(product.sku)
    end

    it "returns 404 for missing product" do
      get "/api/v1/products/99999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/products" do
    let(:valid_params) do
      { product: { name: "New Widget", sku: "WIDGET-001", price: 49.99, stock: 20, category_id: category.id } }
    end

    it "creates a product and returns 201" do
      post "/api/v1/products", params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["name"]).to eq("New Widget")
    end

    it "returns 422 for invalid params" do
      post "/api/v1/products", params: { product: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
