def test_transaction(cart_items, origin, destination)
  TaxCloud::Transaction.new(customer_id: SecureRandom.hex(8), cart_id: SecureRandom.hex(8), order_id: SecureRandom.hex(8), cart_items: cart_items, origin: origin, destination: destination)
end
