require "promo/version"

require 'promo/promocode'
require 'promo/history'

module Promo
end

class PromocodeException < StandardError; end
class UsedPromocode < PromocodeException; end
class ExpiredPromocode < PromocodeException; end
class InvalidPromocode < PromocodeException; end
class InvalidPromoProduct < PromocodeException; end
