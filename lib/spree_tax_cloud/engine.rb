# frozen_string_literal: true

module SpreeTaxCloud
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_tax_cloud'

    config.autoload_paths += %W[#{config.root}/lib]

    # use rspec for tests
    config.generators do |generator|
      generator.test_framework :rspec
    end

    initializer 'spree_tax_cloud.permitted_attributes' do |_app|
      Spree::PermittedAttributes.product_attributes << :tax_cloud_tic
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/decorators/**/*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      if SolidusSupport.frontend_available?
        Rails.application.config.assets.precompile += %w[
          lib/assets/javascripts/spree/frontend/spree_tax_cloud.js
          lib/assets/stylesheets/spree/frontend/spree_tax_cloud.css
        ]
      end
    end

    if SolidusSupport.backend_available?
      paths['app/controllers'] << 'lib/controllers/admin'
    end

    if SolidusSupport.frontend_available?
      paths['app/controllers'] << 'lib/controllers/frontend'
    end

    config.to_prepare &method(:activate).to_proc
  end
end
