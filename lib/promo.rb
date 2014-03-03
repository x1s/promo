require "promo/version"

require 'promo/promocode'
require 'promo/history'
require 'promo/usage'

# Load helpers in case of a rails application
require 'promo/railtie' if defined?(Rails)

module Promo
end

class PromocodeException < StandardError; end
class UsedPromocode < PromocodeException; end
class ExpiredPromocode < PromocodeException; end
class InvalidPromocode < PromocodeException; end
class InvalidPromoProduct < PromocodeException; end

