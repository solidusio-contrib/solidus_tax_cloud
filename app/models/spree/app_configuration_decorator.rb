Spree::AppConfiguration.class_eval do
  preference :taxcloud_default_product_tic, :string, default: '00000'
  preference :taxcloud_shipping_tic, :string, default: '11010'
  Rails.application.config.spree.calculators.tax_rates << Spree::Calculator::TaxCloudCalculator
end
