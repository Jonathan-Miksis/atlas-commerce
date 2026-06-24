require "rails_helper"

RSpec.describe "Health", type: :request do
  describe "GET /health" do
    it "returns HTTP 200" do
      get "/health"
      expect(response).to have_http_status(:ok)
    end

    it "returns status ok" do
      get "/health"
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("ok")
    end

    it "returns app name" do
      get "/health"
      json = JSON.parse(response.body)
      expect(json["app"]).to eq("Atlas Commerce API")
    end

    it "returns database status" do
      get "/health"
      json = JSON.parse(response.body)
      expect(json["database"]).to eq("connected")
    end
  end
end
