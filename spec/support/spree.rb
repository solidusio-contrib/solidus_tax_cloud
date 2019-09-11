require 'spree/testing_support/controller_requests'

RSpec.configure do |config|
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
end
