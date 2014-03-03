module Promo
  module ViewHelpers
    def show_promo_status status
      case status
      when Promo::STATUS[:valid]
        'válido'
      when Promo::STATUS[:expired]
        'expirado'
      when Promo::STATUS[:invalid]
        'inválido'
      when Promo::STATUS[:used]
        'usado'
      end
    end
  end
end