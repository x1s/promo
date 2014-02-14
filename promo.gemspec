# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'promo/version'

Gem::Specification.new do |spec|
  spec.name          = "promo"
  spec.version       = Promo::VERSION
  spec.authors       = ["Pedro Ivo"]
  spec.email         = ["pedroivo@x1s.eti.br"]
  spec.summary       = %q{Create coupons and promocodes}
  spec.description   = %q{}
  spec.homepage      = "http://github.com/x1s"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
