# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"

require File.expand_path('dummy/config/environment.rb', __dir__)

require 'solidus_support'
require "solidus_support/extension/feature_helper"
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/capybara_ext'

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

FactoryBot.find_definitions

RSpec.configure do |config|

  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!

  config.example_status_persistence_file_path = "./spec/examples.txt"

  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, type: :controller

  # Official verification and test harness login credentials provided 7/8/14
  # by David Campbell of The Federal Tax Authority.
  # This account is configured to collect sales tax in the 24 SSUTA states:
  # AR, GA, IN, IA, KS, KY, MI, MN, NE, NV, NJ, NC, ND, OH, OK, RI, SD, TN, UT, VT, WA, WV, WI, and WY
  # The account does not collect sales tax in the remaining sales tax states:
  # AL, AK, AZ, CA, CO, CT, DC, FL, HI, ID, IL, LA, ME, MD, MA, MS, MO, NM, NY, PA, SC, TX, and VA
  config.before :suite do
    TaxCloud.configure do |config|
      config.api_login_id = '2D7D820'
      config.api_key = '0946110C-2AA9-4387-AD5C-4E1C551B8D0C'
    end
  end

  config.before do
    stub_spree_preferences(taxcloud_default_product_tic: '00000', taxcloud_shipping_tic: '11010')
  end
end
