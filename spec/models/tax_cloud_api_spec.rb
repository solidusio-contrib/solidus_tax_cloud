require 'spec_helper'

# This spec ensures that the low-level TaxCloud API returns the values specified by the TaxCloud Implementation Guide.
# If any errors are found in the Solidus-related feature specs, this will serve as a means for verifying whether the errors
# are coming from the TaxCloud gem or API, or whether they are related to the Solidus integration specifically.

describe 'Models' do
  origin = TaxCloud::Address.new(address1: '3121 West Government Way', city: 'Seattle', state: 'WA', zip5: '98199', zip4: '1402')

  it 'TaxCloud Test Case 1a: Verify Address with error' do
    destination = TaxCloud::Address.new(address1: '1 3rd Street', city: 'Seattle', state: 'WA', zip5: '98001')
    cart_items = []
    cart_items << TaxCloud::CartItem.new(index: 0, item_id: 'TestItem1', tic: '00000', quantity: 1, price: 10.00)
    transaction = test_transaction(cart_items, origin, destination)

    result = transaction.lookup

    # From TaxCloud:
    # This address will not verify correctly (the VerifyAddress API call will return an error).
    # That is okay. Occasionally an address cannot be verified. When that happens, pass the
    # destination address as originally entered to Lookup. The address can still be passed to
    # Lookup. The only error that should prevent an order from proceeding is when a customer
    # provided zip code does not exist within the customer provided state (discussed later in Test
    # Case 7, Handling Errors).

    expect { destination.verify }.to raise_error(TaxCloud::Errors::ApiError)

    expect(result.cart_items.size).to eq 1
    expect(result.cart_items.first.cart_item_index).to eq 0
    expect(result.cart_items.first.tax_amount).to eq 1.0
  end

  it 'TaxCloud Test Case 1b: Verify Address without error' do
    destination = TaxCloud::Address.new(address1: '16422 SE 128th St', city: 'Renton', state: 'WA', zip5: '98059')
    cart_items = []
    cart_items << TaxCloud::CartItem.new(index: 0, item_id: 'TestItem2', tic: '00000', quantity: 1, price: 10.00)
    transaction = test_transaction(cart_items, origin, destination)

    result = transaction.lookup

    # From TaxCloud:
    # The destination address used as-is will not give the most accurate rate ($1.00 in tax).
    # The verified address will have a Plus4 Zip Code of 98059-8625 give a correct result
    # ($0.86 in tax).

    expect(result.cart_items.size).to eq 1
    expect(result.cart_items.first.cart_item_index).to eq 0
    expect(result.cart_items.first.tax_amount).to eq 0.86
  end

  it 'TaxCloud Test Case 2a: If all items in cart are tax exempt, shipping is not taxed (in some states)' do
    destination = TaxCloud::Address.new(address1: '75 Rev Martin Luther King Jr Drive', city: 'St. Paul', state: 'MN', zip5: '55155')
    cart_items = []
    cart_items << TaxCloud::CartItem.new(index: 0, item_id: 'Shirt001', tic: '20010', quantity: 1, price: 10.00)
    cart_items << TaxCloud::CartItem.new(index: 1, item_id: 'Shipping', tic: '11010', quantity: 1, price: 10.00)
    transaction = test_transaction(cart_items, origin, destination)

    result = transaction.lookup

    expect(result.cart_items.size).to eq 2
    expect(result.cart_items.detect { |i| i.cart_item_index == 0 }.tax_amount).to eq 0
    expect(result.cart_items.detect { |i| i.cart_item_index == 1 }.tax_amount).to eq 0

    # capture = transaction.authorized_with_capture
    # expect(capture).to eq('OK')
  end

  it 'TaxCloud Test Case 2b: With both taxable and tax exempt items, shipping is taxable' do
    destination = TaxCloud::Address.new(address1: '75 Rev Martin Luther King Jr Drive', city: 'St. Paul', state: 'MN', zip5: '55155')
    cart_items = []
    cart_items << TaxCloud::CartItem.new(index: 0, item_id: 'Shirt001', tic: '20010', quantity: 1, price: 10.00)
    cart_items << TaxCloud::CartItem.new(index: 1, item_id: 'Gadget001', tic: '00000', quantity: 1, price: 10.00)
    cart_items << TaxCloud::CartItem.new(index: 2, item_id: 'Shipping', tic: '11010', quantity: 1, price: 10.00)
    transaction = test_transaction(cart_items, origin, destination)

    result = transaction.lookup

    expect(result.cart_items.size).to eq 3
    expect(result.cart_items.detect { |i| i.cart_item_index == 0 }.tax_amount).to eq 0
    expect(result.cart_items.detect { |i| i.cart_item_index == 1 }.tax_amount).to eq 0.79
    expect(result.cart_items.detect { |i| i.cart_item_index == 2 }.tax_amount).to eq 0.79

    # capture = transaction.authorized_with_capture
    # expect(capture).to eq('OK')
  end

  it 'TaxCloud Test Case 3: Item taxable, shipping not taxable' do
    destination = TaxCloud::Address.new(address1: '2300 N Lincoln Blvd', city: 'Oklahoma City', state: 'OK', zip5: '73105')
    cart_items = []
    cart_items << TaxCloud::CartItem.new(index: 0, item_id: 'Shirt002', tic: '20010', quantity: 1, price: 10.00)
    cart_items << TaxCloud::CartItem.new(index: 1, item_id: 'Shipping', tic: '11010', quantity: 1, price: 10.00)
    transaction = test_transaction(cart_items, origin, destination)

    result = transaction.lookup

    expect(result.cart_items.size).to eq 2
    expect(result.cart_items.detect { |i| i.cart_item_index == 0 }.tax_amount).to eq 0.86
    expect(result.cart_items.detect { |i| i.cart_item_index == 1 }.tax_amount).to eq 0

    # capture = transaction.authorized_with_capture
    # expect(capture).to eq('OK')
  end

  skip 'TaxCloud Test Case 4: Return all items in previous order' do
    # TODO
  end

  skip 'TaxCloud Test Case 5: Return single item in previous order' do
    # TODO
  end

  it 'TaxCloud Test Case 6: Item and shipping taxable' do
    destination = TaxCloud::Address.new(address1: '384 Northyards Blvd NW', city: 'Atlanta', state: 'GA', zip5: '30313')
    cart_items = []
    cart_items << TaxCloud::CartItem.new(index: 0, item_id: 'Shirt003', tic: '20010', quantity: 1, price: 10.00)
    cart_items << TaxCloud::CartItem.new(index: 1, item_id: 'Shipping', tic: '11010', quantity: 1, price: 10.00)
    transaction = test_transaction(cart_items, origin, destination)

    result = transaction.lookup

    expect(result.cart_items.size).to eq 2
    expect(result.cart_items.detect { |i| i.cart_item_index == 0 }.tax_amount).to eq 0.89
    expect(result.cart_items.detect { |i| i.cart_item_index == 1 }.tax_amount).to eq 0.89
  end

  it 'TaxCloud Test Case 7: Handling errors' do
    destination = TaxCloud::Address.new(address1: '384 Northyards Blvd NW', city: 'Atlanta', state: 'GA', zip5: '30313', zip4: '2440')
    cart_items = []
    cart_items << TaxCloud::CartItem.new(index: 0, item_id: 'Gadget002', tic: '00000', quantity: 1, price: -5.00)
    transaction = test_transaction(cart_items, origin, destination)

    expect { transaction.lookup }.to raise_error(TaxCloud::Errors::ApiError)

    begin
      transaction.lookup
    rescue StandardError => e
      expect(e.problem).to eq('Cart Item 0 has a negative Price (-5).  Only positive values can be used')
    end
  end
end
