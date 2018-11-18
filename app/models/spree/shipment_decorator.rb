Spree::Shipment.class_eval do
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
end
