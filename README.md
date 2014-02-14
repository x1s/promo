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

    # gem install promo

Objects must always be created through generate method instead using new.
Here you may define some options:

```ruby
promo = Promo.generate(options)

options.multiple: false
options.quantity: 1
options.type: :percentage
options.status: :valid
options.expires: 4.weeks
options.code: SecureRandom.hex(4)
options.product: Some model with has_many :promocodes, as: :product
```

### Then you can calculate the discount by

```ruby
promo.apply_cart(group_of_products)
promo.calculate_discount(value, [product, group_of_products])
promo.use(options)
```

### Administration view

```ruby
# if you require 'sinatra' you get the DSL extended to Object
gem 'sinatra', '>= 1.3.0', :require => nil
```

Add the following to your config/routes.rb:

```ruby
require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq'
```

## Contributing

1. Fork it ( http://github.com/x1s/promo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
