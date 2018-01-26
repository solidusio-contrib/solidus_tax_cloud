Deface::Override.new(
  virtual_path:  'spree/admin/shared/_configuration_menu',
  name: 'add_tax_cloud_admin_menu_link',
  insert_bottom: "[data-hook='admin_configurations_sidebar_menu']",
  text: "<%= configurations_sidebar_menu_item 'TaxCloud Settings', edit_admin_tax_cloud_settings_path %>",
  original: 'dcaffe234d5b43d5b7673bc13f227500957c9e73'
)
