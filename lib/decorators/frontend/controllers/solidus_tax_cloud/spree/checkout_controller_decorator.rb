# frozen_string_literal: true

module SolidusTaxCloud
  module Spree
    module CheckoutControllerDecorator
      def self.prepended(base)
        base.class_eval do
          rescue_from SolidusTaxCloud::Error do |exception|
            flash[:error] = exception.message
            redirect_to checkout_state_path(:address)
          end

          rescue_from TaxCloud::Errors::ApiError do |exception|
            exception_message = exception.problem
            flash[:error] = I18n.t('spree.address_verification_failed') + (exception_message ? ": #{exception_message}" : '')
            redirect_to checkout_state_path(:address)
          end
        end
      end

      ::Spree::CheckoutController.prepend self
    end
  end
end
