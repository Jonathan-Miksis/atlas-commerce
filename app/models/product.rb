class Product < ApplicationRecord
  belongs_to :category

  validates :name,  presence: true, length: { minimum: 2, maximum: 200 }
  validates :sku,   presence: true, uniqueness: true,
                    format: { with: /\A[A-Z0-9\-]+\z/, message: "must be uppercase letters, numbers, and hyphens only" }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  scope :active,    -> { where(active: true) }
  scope :featured,  -> { where(featured: true) }
  scope :in_stock,  -> { where("stock > 0") }
  scope :by_category, ->(category_id) { where(category_id: category_id) }

  def in_stock?
    stock > 0
  end

  def discounted_price(percent)
    raise ArgumentError, "Discount must be between 0 and 100" unless percent.between?(0, 100)

    (price * (1 - percent / 100.0)).round(2)
  end


  def bulk_price(quantity)
    raise ArgumentError, 'Quantity must be positive' unless quantity.positive?

    discount = case quantity
               when 1..9   then 0
               when 10..49 then 5
               when 50..99 then 10
               else 15
               end
    discounted_price(discount)
  end
end
