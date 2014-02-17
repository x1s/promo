class CreatePromoPromocode < ActiveRecord::Migration
  def change
    create_table :promo_promocodes do |t|
      t.references :product, polymorphic: true, index: true
      t.references :cart, polymorphic: true, index: true
      t.references :order, polymorphic: true, index: true
      t.integer :value, default: 0
      t.integer :promo_type, null: false
      t.integer :status, default: 1
      t.integer :quantity, default: 1
      t.integer :used, default: 0
      t.datetime :expires, null: false
      t.string :code, null: false, index: true
      t.datetime :used_at

      t.timestamps
    end
  end
end