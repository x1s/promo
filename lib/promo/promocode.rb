module Promo

  STATUS = { valid: 0, expired: 1, invalid: 2, used: 3}
  TYPE = { percentage: 1, fixed_value: 0 }

  class Promocode < ActiveRecord::Base
    self.table_name = 'promo_promocodes'
    # Forbide direct creation of objects
    private_class_method :create

    belongs_to :product, polymorphic: true

    has_many :histories, :class_name => 'Promo::History', :foreign_key => "promo_promocode_id"
    has_many :carts, through: :histories
    has_many :orders, through: :histories

    validates :code, uniqueness: true

    scope :last, -> { where(status: Promo::STATUS[:valid]).order(id: :desc).limit(10) }
    scope :used, -> { where(status: Promo::STATUS[:used]).order(used_at: :desc) }
    scope :invalid, -> { where(status: Promo::STATUS[:invalid]).order(used_at: :desc) }
    scope :expired, -> { where("status = ? OR expires < ?", Promo::STATUS[:expired], Time.now).order(expires: :desc) }

    # Objects must always be created through generate method instead using new.
    # here you may define some options:
    #  options.multiple: false
    #  options.quantity: 1
    #  options.type: :percentage
    #  options.status: :valid
    #  options.expires: 4.weeks
    #  options.code: SecureRandom.hex(4)
    #  options.product: Some model with has_many :promocodes, as: :product
    #  options.product_type: Associate the promocode with a class of product (any product of that class)
    def self.generate(options={})
      options[:multiple] ||= false
      options[:quantity] ||= 1
      options[:quantity] = 1 if options[:quantity].to_i <= 0
      options[:promo_type] ||= Promo::TYPE[:percentage]
      options[:status] ||= Promo::STATUS[:valid]
      options[:expires] ||= Time.now + 4.weeks

      if options[:code].blank?
        options[:code] = generate_code
        generated_code = true
      else
        generated_code = false
        options[:code] = generate_code(0,options[:code])
      end

      multiple = options[:multiple]
      options.delete(:multiple)

      if multiple
        ret = []
        many = options[:quantity].to_i
        options[:quantity] = 1
        many.times do |item|
          opt = options.dup
          opt[:code] = generate_code if generated_code
          opt[:code] = generate_code(0,options[:code]+item.to_s) if !generated_code
          ret << create!(opt)
        end
        return ret
      end
      create!(options)
    end

    #--------------------------

    def use (options={})
      is_valid? options

      self.used += 1
      self.status = Promo::STATUS[:used] if self.quantity == self.used
      self.used_at = Time.now
      save
      self
    end

    def invalidate!
      update_attributes(status: Promo::STATUS[:invalid], used_at: Time.now)
    end

    #--------------------------

    def has_product?
      !self.product.nil?
    end

    def is_percentage?
      self.promo_type == Promo::TYPE[:percentage]
    end

    def is_fixed_value?
      self.promo_type == Promo::TYPE[:fixed_value]
    end

    def is_expired?
      return true if self.status == Promo::STATUS[:expired]
      return false if self.expires > Time.now
      update_attribute(:status, Promo::STATUS[:expired])
      true
    end


    # Validates the use of this promocode
    # Options:
    #  product_list: Array with products, mandatory when the promocode is associated with
    #                a specific product or a specific category of products
    #    
    def is_valid?(options={})
      raise UsedPromocode.new 'promocode.messages.already_used' if self.status == Promo::STATUS[:used]
      raise InvalidPromocode.new 'promocode.messages.invalid' if self.status != Promo::STATUS[:valid]
      raise ExpiredPromocode.new 'promocode.messages.expired' if is_expired?

      # Validating use with a specific product associated
      if self.has_product?
        logger.debug "#------------ Promocode associated with a product"
        raise InvalidPromocode.new 'promocode.messages.invalid_use' if options[:product_list].nil?
        if self.product && !options[:product_list].include?(self.product)
          logger.debug "#--------------- Product associated not found on the list"
          raise InvalidPromoProduct.new 'promocode.messages.not_valid_for'
        end
      end

      # Validating use with when a class of product is associated with the promocode
      # not a specific product (no product_id defined)
      if self.product_id.nil? && !self.product_type.nil?
        logger.debug "#------------ Promocode associated with a class"
        raise InvalidPromocode.new 'promocode.messages.invalid_use' if options[:product_list].nil?
        if options[:product_list].none? { |p| p.class.to_s == self.product_type }
          logger.debug "#--------------- Class associated not found on the list"
          raise InvalidPromoProduct.new 'promocode.messages.must_have_course'
        end
      end
      # Returns the promocode if it's valid
      self
    end

    # Generate random codes
    def self.generate_code(size=4,code="")
      code = SecureRandom.hex(size) if code.empty?
      code = code+SecureRandom.hex(size) unless code.empty?
      # Validates if the code is already created, then add something to the name
      if Promo::Promocode.where(code: code).first
        code = code+SecureRandom.hex(1)
      end
      code
    end
  end
end
