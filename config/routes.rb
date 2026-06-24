Rails.application.routes.draw do
  # Health check — used by CI and deployment tooling
  get "/health", to: "health#show"

  namespace :api do
    namespace :v1 do
      resources :categories, only: [:index, :show]
      resources :products, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get :featured
        end
      end
    end
  end

  root to: "health#show"
end
