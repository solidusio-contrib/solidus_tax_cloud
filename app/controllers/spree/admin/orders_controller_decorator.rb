Spree::Admin::OrdersController.class_eval do
  rescue_from TaxCloud::Errors::ApiError do |exception|
    exception_message = exception.problem
    flash[:error] = Spree.t(:address_verification_failed) + (exception_message ? ": #{exception_message}" : '')
    redirect_to edit_admin_order_customer_path(@order)
  end
end
