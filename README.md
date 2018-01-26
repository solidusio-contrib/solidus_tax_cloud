Solidus::TaxCloud 
=======================

Solidus::TaxCloud is a US sales tax extension for Solidus using the Tax Cloud service.

[![Build Status](https://travis-ci.org/solidusio-contrib/solidus_tax_cloud.svg?branch=master)](https://travis-ci.org/solidusio-contrib/solidus_tax_cloud)

TaxCloud Configuration
-----

1. Create an account with Tax Cloud ([https://taxcloud.net](https://taxcloud.net))...

2. ...and get an `api_id` and `api_key`.

3. Go to `Your Account` >> `Tax States`, and turn on sales tax collection for the relevant states in which you want/need to collect sales tax. (**NOTE:** Unless states are explicitly added, TaxCloud will return zero sales tax by default for orders shipping to those states.)


Solidus Configuration
------------------------

## Installation

1. Add this extension to your Gemfile with this line:
  ```ruby
  gem 'spree_tax_cloud', github: 'solidusio-contrib/solidus_tax_cloud'
  ```

  Note that the gem currently uses the Spree namespace internally (as does Solidus itself).
  
  **Update:** Following the guidelines of the Solidus core team, extensions are now meant to be compatible with multiple releases of Solidus. In the past, the branch (`v2.1`) of this extension was meant to match the version of Solidus being used. The new best practice is to use the `master` branch if you are using any version of Solidus from 2.2 onward.

2. Install the gem using Bundler:
  ```ruby
  bundle install
  ```

3. Copy & run migrations
  ```ruby
  bundle exec rails g spree_tax_cloud:install
  ```

4. Create an initializer file with your TaxCloud credentials

**If you are upgrading from version 2.x to version 3.x of this extension, the setting of preferences has changed, and your app will need to be updated accordingly.**

**config/initializers/tax_cloud.rb**
  ```ruby
  TaxCloud.configure do |config|
    config.api_login_id = 'YOUR_TAX_CLOUD_API_ID'
    config.api_key = 'YOUR_TAX_CLOUD_API_KEY'
  end
  ```

5. Restart your server

  If your server was running, restart it so that it can find the assets properly.

In the Admin section of Solidus, within Settings > Store > TaxCloud Settings, you can configure the default Product TIC and Shipping TIC for TaxCloud to use, although it is recommended to leave the defaults as is: `00000` for product default and `11010` for shipping default.

All Products will default to the default product TIC specified here unless they are given an explicit value.
Specific product-level TICs may be specified per-product in the Products section of the Solidus admin backend. If you are uncertain about the correct TIC for a product (whether it be clothing, books, etc.), taxability code information may be obtained from [Tax Cloud](https://taxcloud.net/tic/default.aspx).

To complete your Solidus::TaxCloud configuration, you will need to create a TaxRate to apply rates obtained from Tax Cloud to your Spree LineItems and Shipments.
Under Configuration select Tax Rates, and click Create a New Tax Rate. Recommended defaults are as follows:

- Name: `Sales Tax` (This label will be visible to users during the checkout process)
- Zone: `USA` (Note that TaxCloud is only designed for United States sales tax)
- Rate: `0.0` (Note that the actual rates will be applied by the calculator)
- Tax Category: `Taxable`
- Included in Price: `False` (US taxes are 'additional' rather than 'included')
- Show Rate in Label: `False` (We will not display the static rate, which is left at `0%`)
- Calculator: `Tax Cloud`

Notes
------------------------

- Solidus::TaxCloud is designed to function in a single TaxCategory. It is expected that all Products and all ShippingMethods will be in the same TaxCategory as the one configured for the TaxRate using the Tax Cloud calculator above (in this example, `Taxable`).
- Solidus::TaxCloud is designed to perform all US-related tax calculation itself, and as such does not use Solidus configuration like TaxCategories to specify whether goods are Taxable, Tax-Exempt, Clothing, Food, etc.
- Solidus::TaxCloud does not use the Solidus configuration `tax_address` (which specifies whether the shipping or billing address should be used to compute tax), instead _always_ using the shipping address if possible, and only falling back to the billing address if the shipping address is `nil`. (Asking Spree::TaxCloud to compute orders whose shipping _and_ billing addresses are `nil` will result in an exception.)

TODO
----

Some work on the Solidus:TaxCloud extension is ongoing. Namely:

- [ ] Address Validation: Currently this extension will attempt to validate and correct the destination address (but not the origin) to compute the most accurate tax. However, the corrected address will not be saved in Solidus, and there is no user-facing UI step on the frontend (user specifies a shipping address) or the backend (admin specifies the stock location origin address). Ideally we would want to build out a step in the checkout flow as well as the admininstration backend showing the user the differences in the validated address (typically the zip+4 being added) and asking the user if they would like to update their address accordingly.

- [ ] Split Shipments: Scope Tax Cloud transactions to Shipments rather than Orders, to account for the unusual cases where sales tax depends on the origin address as well as, or instead of, the destination address.

- [ ] Item Returns: Create feature specs and make the appropriate API calls to properly process sales tax on item returns.

- [ ] Promotions: Solidus::TaxCloud is not (yet) fully compatible with some types of Solidus promotions. For instance in cases such as "$10 off all orders over $100," it is not explicit how such a discount will affect the costs of individual items. In these cases, Solidus::TaxCloud will fall back to charging sales tax on the full (undiscounted) item price.

Discussion and pull requests addressing this functionality are welcomed.

License and Acknowledgments
---------

Solidus::TaxCloud is based on the [spree-contrib community extension](https://github.com/spree-contrib/spree_tax_cloud), which was in turn based on the earlier Spree [extension](https://github.com/jetsgit/spree_tax_cloud) by Jerrold R Thompson ([MIT License](http://jet.mit-license.org/)), which was in turn based on the earlier work of Chris Mar and the [TaxCloud gem](https://github.com/drewtempelmeyer/tax_cloud) by Drew Tempelmeyer.
