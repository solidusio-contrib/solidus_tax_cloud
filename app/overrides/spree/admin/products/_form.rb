Deface::Override.new(
  virtual_path: 'spree/admin/products/_form',
  name: 'add_tic_to_admin_product_edit',
  insert_after: "[data-hook='admin_product_form_tax_category']",
  partial: 'spree/admin/products/edit_tax_cloud_tic',
  original: 'a6d7d1941bde020c34025a78466febd8453cf71a'
)
