module Promo
  class History < ActiveRecord::Base
    self.table_name = 'promo_histories'
    belongs_to :cart
    belongs_to :order
    belongs_to :promocode
  end
end