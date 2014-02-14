module Promo
  class Usage

    def use (options={})
      is_valid? options

      self.used += 1
      self.status = STATUS[:used] if self.quantity == self.used
      self.used_at = Time.now
      save
      self
    end

    def discount_value_for (cart)

      discount = 0.0

      if self.product
        # Then, check if the product is already in te cart
        item = cart.find_item(self.product)

        if !item.nil?
          product = item.product
          if self.is_percentage?
            discount = (product.price.to_f * (self.value.to_f/100))
            item.update_attribute(:discount_percent, self.value.to_f)
          else
            discount = self.value.to_f < product.price.to_f ? self.value.to_f : product.price.to_f
          end
          item.update_attribute(:discount_value, discount)
        end

      else
        # cases when the promocode is not associated with a specific product
        if self.product_type == 'Course'
          item = cart.get_first_course
          # it was created on a open giftcard (any product)

          if !item.nil?
            product = item.product
            if self.is_percentage?
              discount = (product.price.to_f * (self.value.to_f/100))
              item.update_attribute(:discount_percent, self.value.to_f)
            else
              discount = self.value.to_f < product.price.to_f ? self.value.to_f : product.price.to_f
            end
          end
        elsif self.product_type == 'CourseModule'
          item = cart.get_first_module
          # it was created on a open gitcard (aplied to any module)
         if !item.nil?
            product = item.product
            if self.is_percentage?
              discount = (product.price.to_f * (self.value.to_f/100))
              item.update_attribute(:discount_percent, self.value.to_f)
            else
              discount = self.value.to_f < product.price.to_f ? self.value.to_f : product.price.to_f
            end
          end
        else
          # Not associated with any product, apply it to the whole cart
          if self.is_percentage?
            discount = (cart.full_value(false) * (self.value.to_f/100))
          else
            discount = self.value.to_f
          end

        end
      end

      discount
    end

    def self.use_in_cart(cart)
      promo = Promocode.find_by(id: cart.promocode.id)
      promo.use ({ cart: cart })
    end

    def self.apply_cart(cart)
      # retrieves the total value from a cart, without calculating promocodes
      value_with_discounts = cart.full_value false

      if !cart.promocode.blank?
        promo = find_by(id: cart.promocode.id)
        value_with_discounts -= promo.discount_value_for cart
      end

      if value_with_discounts.nil? || value_with_discounts < 0
        value_with_discounts = 0
      end

      value_with_discounts.to_f
    end

  end
end
