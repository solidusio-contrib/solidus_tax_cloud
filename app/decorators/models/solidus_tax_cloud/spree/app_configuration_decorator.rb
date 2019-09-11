module SolidusTaxCloud
  module Spree
    module AppConfigurationDecorator
      def self.prepended(base)
        base.class_eval do
          preference :taxcloud_default_product_tic, :string, default: '00000'
          preference :taxcloud_shipping_tic, :string, default: '11010'
        end

        Rails.application.config.spree.calculators.tax_rates << ::Spree::Calculator::TaxCloudCalculator
      end

      ::Spree::AppConfiguration.prepend self
    end
  end
end
