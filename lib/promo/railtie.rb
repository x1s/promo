require 'promo/view_helpers'
module Promo
  class Railtie < Rails::Railtie
    initializer "promo.view_helpers" do
      ActionView::Base.send :include, Promo::ViewHelpers
    end
  end
end