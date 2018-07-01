Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY

  s.name        = 'spree_tax_cloud'
  s.version     = '3.1.0'
  s.authors     = ['Jerrold Thompson']
  s.email       = 'jet@whidbey.com'
  s.homepage    = 'https://github.com/spree-contrib/spree_tax_cloud.git'
  s.summary     = 'Solidus extension providing Tax Cloud services'
  s.description = 'Solidus extension for providing Tax Cloud services in USA.'

  s.required_ruby_version = '>= 2.4.0'

  s.add_dependency 'solidus_api'
  s.add_dependency 'solidus_backend'
  s.add_dependency 'solidus_core', ['>= 1.2.0', '< 3']

  s.add_dependency 'savon', '~> 2.12.0'
  s.add_dependency 'tax_cloud', '~> 0.3.0'
  s.add_dependency 'rails', '< 5.2.0' # TODO: Relax this for full Solidus 2.6 support

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'generator_spec'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-stack_explorer'
  s.add_development_dependency 'puma'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'solidus_frontend'
  s.add_development_dependency 'sqlite3'
end
