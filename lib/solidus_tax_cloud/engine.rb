# frozen_string_literal: true

require 'spree/core'
require 'solidus_tax_cloud'

module SolidusTaxCloud
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_tax_cloud'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'solidus_tax_cloud.permitted_attributes' do |_app|
      Spree::PermittedAttributes.product_attributes << :tax_cloud_tic
    end
  end
end
