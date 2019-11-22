# frozen_string_literal: true

module SolidusTaxCloud
  module Spree
    module Admin
      module OrdersControllerDecorator
        def self.prepended(base)
          base.class_eval do
            rescue_from TaxCloud::Errors::ApiError do |exception|
              exception_message = exception.problem
              flash[:error] = I18n.t('spree.address_verification_failed') + (exception_message ? ": #{exception_message}" : '')
              redirect_to edit_admin_order_customer_path(@order)
            end
          end
        end

        ::Spree::Admin::OrdersController.prepend(self) if SolidusSupport.backend_available?
      end
    end
  end
end
