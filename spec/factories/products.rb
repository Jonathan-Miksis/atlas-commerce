FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:sku)  { |n| "SKU-#{n.to_s.rjust(4, '0')}" }
    description { "A test product" }
    price { 99.99 }
    stock { 10 }
    featured { false }
    active { true }
    association :category

    trait :featured do
      featured { true }
    end

    trait :out_of_stock do
      stock { 0 }
    end

    trait :inactive do
      active { false }
    end
  end
end
