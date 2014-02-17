class CreatePromoHistory < ActiveRecord::Migration
  def change
    create_table :promo_histories do |t|
      t.references :cart, polymorphic: true, index: true
      t.references :order, polymorphic: true, index: true
      t.references :promo_promocode, index: true
      t.timestamps
    end
  end
end
