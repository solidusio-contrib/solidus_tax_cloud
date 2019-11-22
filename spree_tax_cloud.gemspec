# frozen_string_literal: true

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY

  s.name        = 'spree_tax_cloud'
  s.version     = '3.2.0'
  s.authors     = ['Jerrold Thompson']
  s.email       = 'jet@whidbey.com'
  s.homepage    = 'https://github.com/spree-contrib/spree_tax_cloud.git'
  s.summary     = 'Solidus extension providing Tax Cloud services'
  s.description = 'Solidus extension for providing Tax Cloud services in USA.'

  s.required_ruby_version = '>= 2.4.0'

  s.add_dependency 'solidus_api'
  s.add_dependency 'solidus_backend'
  s.add_dependency 'solidus_core', ['>= 1.2.0', '< 3']

  s.add_dependency 'deface'
  s.add_dependency 'savon', '~> 2.12.0'
  s.add_dependency 'tax_cloud', '~> 0.3.0'

  s.add_development_dependency 'generator_spec'
  s.add_development_dependency 'solidus_extension_dev_tools'
end
