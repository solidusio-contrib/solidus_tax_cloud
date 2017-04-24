Spree::LineItem.class_eval do
  def tax_cloud_cache_key
    key = "Spree::LineItem #{id}: #{quantity}x<#{variant.cache_key}>@#{pre_tax_amount}#{currency}"
    if order.ship_address
      key << "shipped_to<#{order.ship_address.try(:cache_key)}>"
    elsif order.billing_address
      key << "billed_to<#{order.bill_address.try(:cache_key)}>"
    end
  end

  def price_with_discounts
    round_to_two_places(pre_tax_amount / quantity)
  end

  def round_to_two_places(amount)
    BigDecimal.new(amount.to_s).round(2, BigDecimal::ROUND_HALF_UP)
  end
end
