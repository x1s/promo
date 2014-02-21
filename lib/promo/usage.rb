module Promo
  class Usage
    class << self
      # Validates the use of any promocode
      # Options (Hash):
      #  code: string with the code used
      #  product_list: array with the products to be evaluated
      def validate (options={})
        promocode = Promo::Promocode.where(code: options[:code]).first
        raise InvalidPromocode.new 'promocode.messages.invalid' if promocode.nil?
        promocode.is_valid? options
      end

      # Calculates the discounts to any list of products
      # Options (Hash):
      #  promocode: Pomo::Promocode object
      #  product_list: array with the products to be evaluated
      def discount_for (options={})
        return 0 if options[:promocode].nil?
        promocode = options[:promocode]
        product_list = options[:product_list]

        return discount_for_product(promocode, product_list) if promocode.has_product?
        if promocode.is_percentage?
          calculate_percentage product_list.map(&:value).reduce(:+), promocode.value
        else
          promocode.value
        end
      end

      # Calculates the dicount for a specific product in the list
      # previously associated with the current promocode
      # Parameters:
      #  promocode: Pomo::Promocode object
      #  product_list: array with the products to be evaluated
      def discount_for_product promocode, product_list
        product = promocode.product
        return 0 unless product_list.include? product
        if promocode.is_percentage?
          calculate_percentage(product.value,promocode.value)
        else
          promocode.value
        end
      end

      #calculates the percentage to a specific value
      def calculate_percentage(value, percent)
        (value * (percent.to_f/100)).to_i
      end
    end
  end
end
