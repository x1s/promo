module Promo
  class Promocode < ActiveRecord::Base
    # Forbide direct creation of objects
    private_class_method :new, :create

    belongs_to :product, polymorphic: true
    has_many :promocode_histories
    has_many :carts, through: :promocode_histories
    has_many :orders, through: :promocode_histories

    validates :code, uniqueness: true

    STATUS = { valid: 0, expired: 1, invalid: 2, used: 3}
    TYPE = { percentage: 1, fixed_value: 0 }

    scope :last, -> { where(status: STATUS[:valid]).order(id: :desc).limit(10) }
    scope :used, -> { where(status: STATUS[:used]).order(used_at: :desc) }
    scope :invalid, -> { where(status: STATUS[:invalid]).order(used_at: :desc) }
    scope :expired, -> { where("status = ? OR expires < ?", STATUS[:expired], Time.now).order(expires: :desc) }

    def is_expired?
      return true if self.status == STATUS[:expired]
      return false if self.expires > Time.now
      update_attribute(:status, STATUS[:expired])
      true
    end

    def invalidate!
      update_attributes(status: STATUS[:invalid], used_at: Time.now)
    end

    def is_valid?(options={})
      raise UsedPromocode.new 'promocode.messages.already_used' if self.status == STATUS[:used]
      raise InvalidPromocode.new 'promocode.messages.invalid' if self.status != STATUS[:valid]
      raise ExpiredPromocode.new 'promocode.messages.expired' if is_expired?

      # Validating use with product associated
      if !self.product.nil?
        raise InvalidPromocode.new 'promocode.messages.invalid_use' if options[:cart].nil?
        if self.product && !options[:cart].has_product?(self.product)
          raise InvalidPromoProduct.new 'promocode.messages.not_valid_for'
        end
      end
      # Validating use with product associated
      if self.product_id.nil? && !self.product_type.nil?
        raise InvalidPromocode.new 'promocode.messages.invalid_use' if options[:cart].nil?
        if self.product_type == 'Course' && !options[:cart].get_first_course
          raise InvalidPromoProduct.new 'promocode.messages.must_have_course'
        end
        if self.product_type == 'CourseModule' && !options[:cart].get_first_module
          raise InvalidPromoProduct.new 'promocode.messages.must_have_module'
        end
      end
      # Validates use of this promocode
      true
    end

    def has_product?
      !self.product.nil?
    end

    def is_percentage?
      self.promo_type == TYPE[:percentage]
    end

    def is_fixed_value?
      self.promo_type == TYPE[:fixed_value]
    end

    # Objects must always be created through generate method instead using new.
    # here you may define some options:
    #  options.multiple: false
    #  options.quantity: 1
    #  options.type: :percentage
    #  options.status: :valid
    #  options.expires: 4.weeks
    #  options.code: SecureRandom.hex(4)
    #  options.product: Some model with has_many :promocodes, as: :product
    def self.generate(options={})
      options[:multiple] ||= false
      options[:quantity] ||= 1
      options[:quantity] = 1 if options[:quantity].to_i <= 0
      options[:promo_type] ||= TYPE[:percentage]
      options[:status] ||= STATUS[:valid]
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

    def self.generate_code(size=4,code="")
      if code.empty?
        code = SecureRandom.hex(size)
      else
        code = code+SecureRandom.hex(size)
      end

      # Validates if the code is already created, then add something to the name
      codebd = Promocode.find_by code: code
      if !codebd.nil?
        code = code+SecureRandom.hex(1)
      end

      code
    end
  end
end
