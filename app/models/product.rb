class Product < ApplicationRecord
  belongs_to :category

  validates :name,  presence: true, length: { minimum: 2, maximum: 200 }
  validates :sku,   presence: true, uniqueness: true,
                    format: { with: /\A[A-Z0-9\-]+\z/, message: "must be uppercase letters, numbers, and hyphens only" }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  scope :active,      -> { where(active: true) }
  scope :featured,    -> { where(featured: true) }
  scope :in_stock,    -> { where("stock > 0") }
  scope :by_category, ->(category_id) { where(category_id: category_id) }

  def in_stock?
    stock > 0
  end

  def discounted_price(percent)
    raise ArgumentError, "Discount must be between 0 and 100" unless percent.between?(0, 100)

    (price * (1 - percent / 100.0)).round(2)
  end

  def bulk_price(quantity)
    raise ArgumentError, "Quantity must be positive" unless quantity.positive?

    discounts = { (1..9) => 0, (10..49) => 5, (50..99) => 10, (100..) => 15 }
    discount = discounts.find { |range, _| range.cover?(quantity) }&.last || 0
    discounted_price(discount)
  end

  def flash_sale_price(sale_percent, starts_at, ends_at)
    raise ArgumentError, "Sale percent must be between 1 and 90" unless sale_percent.between?(1, 90)
    raise ArgumentError, "Sale must end after it starts" unless ends_at > starts_at

    return price unless Time.current.between?(starts_at, ends_at)

    discounted_price(sale_percent)
  end

  def volume_price(customer_tier)
    raise ArgumentError, "Invalid customer tier" unless %w[standard silver gold platinum].include?(customer_tier)

    multipliers = { "standard" => 1.0, "silver" => 0.95, "gold" => 0.90, "platinum" => 0.85 }
    (price * multipliers[customer_tier]).round(2)
  end

  def loyalty_price(years_as_customer)
    raise ArgumentError, "Years must be a non-negative integer" unless years_as_customer.is_a?(Integer) && years_as_customer >= 0

    discount = case years_as_customer
               when 0..1 then 0
               when 2..4 then 3
               when 5..9 then 7
               else 12
               end
    discounted_price(discount)
  end
end
