# frozen_string_literal: true

module SolidusTaxCloud
  module Spree
    module ShipmentDecorator
      def tax_cloud_cache_key
        if ActiveRecord::Base.try(:cache_versioning)
          cache_key
        else
          "#{cache_key}--from:#{stock_location.cache_key}--to:#{order.shipping_address.cache_key}"
        end
      end

      def tax_cloud_cache_version
        if ActiveRecord::Base.try(:cache_versioning)
          "#{cache_version}--from:#{stock_location.cache_version}--to:#{order.shipping_address.cache_version}"
        end
      end

      def price_with_discounts
        total_excluding_vat
      end

      ::Spree::Shipment.prepend self
    end
  end
end
