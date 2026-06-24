module Api
  module V1
    class CategoriesController < ApplicationController
      def index
        categories = Category.ordered.includes(:products)
        render json: categories.map { |c| serialize_category(c) }
      end

      def show
        category = Category.find_by!(slug: params[:id])
        render json: serialize_category(category, include_products: true)
      end

      private

      def serialize_category(category, include_products: false)
        result = {
          id: category.id,
          name: category.name,
          slug: category.slug,
          description: category.description,
          product_count: category.products.active.count
        }
        result[:products] = category.products.active.map { |p| serialize_product_summary(p) } if include_products
        result
      end

      def serialize_product_summary(product)
        { id: product.id, name: product.name, sku: product.sku, price: product.price.to_f }
      end
    end
  end
end
