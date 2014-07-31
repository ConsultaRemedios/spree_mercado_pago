# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_mercado_pago'
  s.version     = '2.1.3'
  s.summary     = 'Mercado Pago Payment for Spree'
  s.description = 'Let Spree proccess your payment with Mercado Pago'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Daniel Pakuschewski'
  s.email     = 'daniel@rocketstud.io'
  s.homepage  = 'http://www.rocketstud.io'

  # s.files       = `git ls-files`.split("\n")
  # s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.1.0'
  s.add_dependency 'mercadopago', '~> 2.0.2'
  s.add_dependency 'json', '>= 1.4.6'
  s.add_dependency 'faraday', '0.9.0'

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
