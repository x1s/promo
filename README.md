# Promo

A gem to generate and use coupons and promocodes

## Installation

Add this line to your application's Gemfile:

    gem 'promo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install promo

## Usage

First you need to create the migrations needed in the gem:

    # rails generate promo:install

Objects must always be created through generate method instead using new.
Here you may define some options:

```ruby
promo = Promo::Promocode.generate(options)

options.multiple: false
options.quantity: 1
options.type: :percentage
options.status: :valid
options.expires: 4.weeks
options.code: SecureRandom.hex(4)
options.product: Some model with has_many :promocodes, as: :product
```

### Associated models

#### Cart / Order
While in a ecommerce, you might have a Cart and Order models (or any correspondency). thus you must associate these models in order to accept the promocodes associated.

In a simple example, we might define a Cart model as:
```ruby
class Cart < ActiveRecord::Base
  has_many :cart_items, dependent: :destroy
  has_one :promo_history, :class_name => 'Promo::History'
  has_one :promocode, through: :promo_history
  ...
end

```

And then, after the checkout that Cart model suppose to be transformed (or coppied) to a Order object, something like:

```ruby
class Order < ActiveRecord::Base
  has_many :order_items, dependent: :destroy
  has_one :promo_history, :class_name => 'Promo::History'
  has_one :promocode, through: :promo_history
  ...
end

```

#### Products

As a promocode may be associated with any kind of product, in the model you want allow it, you must define as

```ruby
class Product < ActiveRecord::Base
  has_many :promocodes, as: :product

  has_many :cart_item, as: :product
  has_many :order_item, as: :product
  
  has_many :carts, through: :cart_item
  has_many :orders, through: :order_item
  ...
end
```

### Then you can calculate the discount by

```ruby
class Cart < ActiveRecord::Base
  def recalculate
    self.update_attribute(:total_value, cart_items.map{ |i| i.product.value }.reduce(:+))
    self.update_attribute(:discount_value, Promo::Usage.discount_for(promocode: self.promocode, product_list: product_list))
    self.update_attribute(:final_value, self.total_value-self.discount_value)
  end
end
```

### Example application
I've created a sample application with a basic product/cart/order model to test the gem, and also might be used as base for any simple ecommerce:

http://github.com/x1s/promo-example-cart

### Administration view

```ruby
# if you require 'sinatra' you get the DSL extended to Object
gem 'sinatra', '>= 1.3.0', :require => nil
```

Add the following to your config/routes.rb:

```ruby
require 'promo/web'
mount Promo::Web => '/promo'
```

## Contributing

1. Fork it ( http://github.com/x1s/promo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
