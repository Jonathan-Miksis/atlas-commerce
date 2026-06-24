module Api
  module V1
    class ProductsController < ApplicationController
      before_action :set_product, only: [:show, :update, :destroy]

      def index
        products = Product.active.includes(:category)
        products = products.by_category(params[:category_id]) if params[:category_id]
        render json: products.map { |p| serialize_product(p) }
      end

      def show
        render json: serialize_product(@product)
      end

      def featured
        products = Product.active.featured.includes(:category)
        render json: products.map { |p| serialize_product(p) }
      end

      def create
        product = Product.create!(product_params)
        render json: serialize_product(product), status: :created
      end

      def update
        @product.update!(product_params)
        render json: serialize_product(@product)
      end

      def destroy
        @product.update!(active: false)
        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_params
        params.require(:product).permit(:name, :sku, :description, :price, :stock, :featured, :active, :category_id)
      end

      def serialize_product(product)
        {
          id: product.id,
          name: product.name,
          sku: product.sku,
          description: product.description,
          price: product.price.to_f,
          stock: product.stock,
          in_stock: product.in_stock?,
          featured: product.featured,
          active: product.active,
          category: {
            id: product.category.id,
            name: product.category.name,
            slug: product.category.slug
          },
          created_at: product.created_at.iso8601,
          updated_at: product.updated_at.iso8601
        }
      end
    end
  end
end
