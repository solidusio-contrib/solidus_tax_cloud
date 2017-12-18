Spree::Shipment.class_eval do
  def tax_cloud_cache_key
    "#{cache_key}--from:#{stock_location.cache_key}--to:#{order.shipping_address.cache_key}"
  end
end
