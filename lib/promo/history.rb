module Promo
  class History < ActiveRecord::Base
    self.table_name = 'promo_histories'
    belongs_to :cart
    belongs_to :order
    belongs_to :promocode, :class_name => 'Promo::Promocode', :foreign_key => "promo_promocode_id"
  end
end