class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string  :name,        null: false
      t.string  :sku,         null: false
      t.text    :description
      t.decimal :price,       precision: 10, scale: 2, null: false
      t.integer :stock,       default: 0, null: false
      t.boolean :featured,    default: false, null: false
      t.boolean :active,      default: true,  null: false
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :products, :sku, unique: true
    add_index :products, :featured
    add_index :products, :active
  end
end
