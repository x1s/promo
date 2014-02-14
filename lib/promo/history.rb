module Promo
  class History < ActiveRecord::Base
    belongs_to :cart
    belongs_to :order
    belongs_to :promocode
  end
end