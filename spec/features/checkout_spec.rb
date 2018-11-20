require 'spec_helper'

describe 'Checkout', js: true do
  let!(:usa) { create(:country, name: 'United States of America', states_required: true) }
  let!(:alabama) { create(:state, name: 'Alabama', abbr: 'AL', country: usa) }
  let!(:georgia) { create(:state, name: 'Georgia', abbr: 'GA', country: usa) }
  let!(:minnesota) { create(:state, name: 'Minnesota', abbr: 'MN', country: usa) }
  let!(:oklahoma) { create(:state, name: 'Oklahoma', abbr: 'OK', country: usa) }
  let!(:washington) { create(:state, name: 'Washington', abbr: 'WA', country: usa) }

  let!(:zone) do
    zone = create(:zone, name: 'US')
    zone.members.create(zoneable: usa)
    zone
  end

  let!(:uk) { create(:country, name: 'United Kingdom', states_required: false, iso_name: 'UNITED KINGDOM', iso: 'UK', iso3: 'GBR', numcode: 826) }
  let!(:uk_address) { create(:address, country: uk, state: nil, zipcode: 'SW1A 1AA') }
  let!(:non_us_zone) do
    zone = create(:zone, name: 'Rest of the world')
    zone.members.create(zoneable: uk)
    zone
  end

  let!(:store) { create(:store) }
  let!(:shipping_calculator) { create(:calculator) }
  # default calculator in the Spree factory is flat rate of $10, which is exactly what we want
  let!(:shipping_method) { create(:shipping_method, tax_category_id: 1, calculator: shipping_calculator, zones: [zone, non_us_zone]) }
  let!(:stock_location) { create(:stock_location, country_id: stock_location_address.country.id, state_id: stock_location_address.state.id, address1: stock_location_address.address1, city: stock_location_address.city, zipcode: stock_location_address.zipcode) }
  let!(:mug) { create(:product, name: 'RoR Mug', price: 10) }
  let!(:shirt) { create(:product, name: 'Shirt', price: 10, tax_cloud_tic: '20010') }
  let!(:payment_method) { create(:check_payment_method) }

  let!(:item_promotion) { create(:promotion, :with_line_item_adjustment, code: 'AAAA', adjustment_rate: 5) }
  let!(:shipping_promotion) do
    promotion = create(:promotion, code: 'BBBB')
    action = Spree::Promotion::Actions::FreeShipping.create!
    promotion.actions << action
    promotion.save!
  end

  let!(:tax_rate) { create(:tax_rate, amount: 0, name: 'Sales Tax', zone: zone, calculator: Spree::Calculator::TaxCloudCalculator.create, tax_category: Spree::TaxCategory.first, show_rate_in_label: false) }
  let!(:flat_tax_rate) { create(:tax_rate, amount: 0.1, name: 'Flat Sales Tax', zone: non_us_zone, tax_category: Spree::TaxCategory.first, show_rate_in_label: false) }

  before do
    stock_location.stock_items.update_all(count_on_hand: 1)
  end

  it 'should display tax lookup error if invalid address' do
    add_to_cart('RoR Mug')
    click_button 'Checkout'

    fill_in 'order_email', with: 'test@example.com'
    fill_in_address(alabama_address)
    fill_in 'order_bill_address_attributes_zipcode', with: '12345'

    click_button 'Save and Continue'
    click_button 'Save and Continue'

    click_button 'Save and Continue'
    expect(page).to have_content(/Address Verification Failed/i)
  end

  it 'should tolerate a missing sku without throwing a Tax Cloud exception' do
    add_to_cart('RoR Mug')
    click_button 'Checkout'

    fill_in 'order_email', with: 'test@example.com'
    fill_in_address(alabama_address)
    Spree::Product.where(name: 'RoR Mug').first.update_attributes(sku: '')

    click_button 'Save and Continue'
    expect(page).not_to have_content(/Address Verification Failed/i)
  end

  it 'should calculate and display tax on payment step and allow full checkout' do
    add_to_cart('RoR Mug')
    click_button 'Checkout'

    fill_in 'order_email', with: 'test@example.com'
    fill_in_address(alabama_address)
    click_button 'Save and Continue'
    click_button 'Save and Continue'

    click_on 'Save and Continue'
    click_on 'Place Order'
    expect(current_path).to match(spree.order_path(Spree::Order.last))
  end

  it 'should not break when removing all items from cart after a tax calculation has been created' do
    add_to_cart('RoR Mug')
    click_button 'Checkout'

    fill_in 'order_email', with: 'test@example.com'
    fill_in_address(alabama_address)
    click_button 'Save and Continue'
    click_button 'Save and Continue'

    # TODO: Address with TaxCloud support why this appears to have changed as of week of 7/1/18
    # expect(page).not_to have_content(/Sales\sTax/i)
    # expect(page).to have_content(/Order Total:\s\$20.00/i) # Alabama orders are configured under this API key to have no tax

    visit spree.cart_path
    find('a.delete').click
    expect(page).to have_content(/Shopping Cart/i)
    expect(page).not_to have_content(/Internal Server Error/i)
  end

  it 'should only calculate using tax cloud for orders that use the tax cloud calculator' do
    add_to_cart('RoR Mug')
    click_button 'Checkout'

    fill_in 'order_email', with: 'test@example.com'
    fill_in_address(uk_address)

    click_button 'Save and Continue'
    # There should not be a check on the address because
    # the rate is not handled by TaxCloud.
    expect(page).not_to have_content(/Address Verification Failed/i)

    click_button 'Save and Continue'
    click_button 'Save and Continue'
    click_button 'Place Order'

    expect(current_path).to match(spree.order_path(Spree::Order.last))
    expect(page).not_to have_content(/Address Verification Failed/i)
  end

  it 'TaxCloud Test Case 1a: Verify Address with error' do
    add_to_cart('RoR Mug')
    click_button 'Checkout'

    fill_in 'order_email', with: 'test@example.com'
    click_button 'Continue'
    expect(page).to have_content(/Order Total:\s\$10/i)
    fill_in_address(test_case_1a_address)
    click_button 'Save and Continue'
    # From TaxCloud:
    # This address will not verify correctly (the VerifyAddress API call will return an error).
    # That is okay. Occasionally an address cannot be verified. When that happens, pass the
    # destination address as originally entered to Lookup. The address can still be passed to
    # Lookup. The only error that should prevent an order from proceeding is when a customer
    # provided zip code does not exist within the customer provided state (discussed later in Test
    # Case 7, Handling Errors).
    #
    # NOTE: In the API specs (from official TaxCloud Implementation Verification Guide), there is
    # no shipping item sent to TaxCloud, and there is only a single $1.00 charge for the item.
    # In this integration test, Solidus will automatically send the shipping information, which
    # results in a second $1.00 charge, for a total tax of $2.00.
    expect(page).to have_content(/Sales Tax\s\$2.00/i)
  end

  it 'TaxCloud Test Case 1b: Verify Address without error' do
    add_to_cart('RoR Mug')
    click_button 'Checkout'

    fill_in 'order_email', with: 'test@example.com'
    click_button 'Continue'
    expect(page).to have_content(/Item Total:\s\$10/i)
    fill_in_address(test_case_1b_address)
    click_button 'Save and Continue'
    # From TaxCloud:
    # The destination address used as-is will not give the most accurate rate ($1.00 in tax).
    # The verified address will have a Plus4 Zip Code of 98059-8625 give a correct result
    # ($0.86 in tax).
    #
    # NOTE: In the API specs (from official TaxCloud Implementation Verification Guide), there is
    # no shipping item sent to TaxCloud, and there is only a single $0.86 charge for the item.
    # In this integration test, Solidus will automatically send the shipping information, which
    # results in a second $0.86 charge, for a total tax of $1.72.
    expect(page).to have_content(/Sales Tax\s\$1.72/i)
  end

  it 'TaxCloud Test Case 2a: If all items in cart are tax exempt, shipping is not taxed (in some states)' do
    add_to_cart('Shirt')
    expect(page).to have_content(/Total\s\$10/i)
    click_button 'Checkout'

    expect(page).to have_content(/Item Total:\s\$10/i)
    fill_in 'order_email', with: 'test@example.com'
    fill_in_address(test_case_2a_address)
    click_button 'Save and Continue'

    expect(page).not_to have_content(/Address Verification Failed/i)
    expect(page).to have_content(/Item Total:\s\$10/i)
    expect(page).to have_content(/Order Total:\s\$20/i)
    click_button 'Save and Continue'

    expect(page).to have_content(/Item Total:\s\$10/i)
    expect(page).to have_content(/Order Total:\s\$20/i)
    click_on 'Save and Continue'

    click_button 'Place Order'

    expect(current_path).to match(spree.order_path(Spree::Order.last))
    expect(page).to have_content(/Sales Tax\s\$0.00/i)
    expect(page).to have_content(/ORDER TOTAL:\s\$20/i)
  end

  it 'TaxCloud Test Case 2b: With both taxable and tax exempt items, shipping is taxable' do
    add_to_cart('RoR Mug')
    add_to_cart('Shirt')
    click_button 'Checkout'

    fill_in 'order_email', with: 'test@example.com'
    click_button 'Continue'
    expect(page).to have_content(/Item Total:\s\$20/i)
    fill_in_address(test_case_2b_address)
    click_button 'Save and Continue'

    click_button 'Save and Continue'

    expect(page).to have_content(/Sales Tax\s\$1.58/i)
    expect(page).to have_content(/Order Total:\s\$31.58/i)

    click_on 'Save and Continue'
    click_button 'Place Order'

    expect(current_path).to match(spree.order_path(Spree::Order.last))
    expect(page).to have_content(/Sales Tax\s\$1.58/i)
    expect(page).to have_content(/ORDER TOTAL:\s\$31.58/i)
  end

  it 'TaxCloud Test Case 3: Item taxable, shipping not taxable' do
    add_to_cart('Shirt')
    click_button 'Checkout'

    fill_in 'order_email', with: 'test@example.com'
    click_button 'Continue'
    expect(page).to have_content(/Item Total:\s\$10/i)
    fill_in_address(test_case_3_address)
    click_button 'Save and Continue'

    expect(page).not_to have_content(/Address Verification Failed/i)
    click_button 'Save and Continue'

    expect(page).to have_content(/Sales Tax\s\$0.86/i)
    expect(page).to have_content(/Order Total:\s\$20.86/i)

    click_on 'Save and Continue'
    click_button 'Place Order'

    expect(current_path).to match(spree.order_path(Spree::Order.last))
    expect(page).to have_content(/Sales Tax\s\$0.86/i)
    expect(page).to have_content(/ORDER TOTAL:\s\$20.86/i)
  end

  skip 'TaxCloud Test Case 4: Return all items in previous order' do
    # TODO
  end

  skip 'TaxCloud Test Case 5: Return single item in previous order' do
    # TODO
  end

  it 'TaxCloud Test Case 6: Item and shipping taxable' do
    add_to_cart('Shirt')
    click_button 'Checkout'

    fill_in 'order_email', with: 'test@example.com'
    click_button 'Continue'
    expect(page).to have_content(/Item Total:\s\$10/i)
    fill_in_address(test_case_6_address)
    click_button 'Save and Continue'

    expect(page).not_to have_content(/Address Verification Failed/i)
    click_button 'Save and Continue'

    expect(page).to have_content(/Sales Tax\s\$1.78/i)
    expect(page).to have_content(/Order Total:\s\$21.78/i)

    click_on 'Save and Continue'
    click_button 'Place Order'

    expect(current_path).to match(spree.order_path(Spree::Order.last))
    expect(page).to have_content(/Sales Tax\s\$1.78/i)
    expect(page).to have_content(/ORDER TOTAL:\s\$21.78/i)
  end

  # it 'TaxCloud Test Case 7: Handling errors' do
  #   NOTE: Solidus does not allow for the creation of negative-price products,
  #   rendering TaxCloud Test Case 7 moot.
  # end

  context 'with discounts' do
    it 'TaxCloud Test Case 3, with item discount' do
      add_to_cart('Shirt')

      fill_in 'order_coupon_code', with: 'AAAA'
      click_button 'Update'
      expect(page).not_to have_content('The coupon code you entered doesn\'t exist.')
      expect(page).to have_content('The coupon code was successfully applied to your order.')
      click_button 'Checkout'

      fill_in 'order_email', with: 'test@example.com'
      click_button 'Continue'
      expect(page).to have_content(/Item Total:\s\$10/i)
      page.should have_content(/Promotion \(Promo\)\s\-\$5.00/i)
      expect(page).to have_content(/Order Total:\s\$5/i)
      fill_in_address(test_case_3_address)
      click_button 'Save and Continue'

      expect(page).not_to have_content(/Address Verification Failed/i)
      click_button 'Save and Continue'

      expect(page).to have_content(/Sales Tax\s\$0.43/i)
      expect(page).to have_content(/Order Total:\s\$15.43/i)
    end

    it 'TaxCloud Test Case 3, with item discount, multiple items' do
      add_to_cart('Shirt')
      add_to_cart('Shirt')

      fill_in 'order_coupon_code', with: 'AAAA'
      click_button 'Update'
      expect(page).not_to have_content('The coupon code you entered doesn\'t exist.')
      expect(page).to have_content('The coupon code was successfully applied to your order.')
      click_button 'Checkout'

      fill_in 'order_email', with: 'test@example.com'
      click_button 'Continue'
      expect(page).to have_content(/Item Total:\s\$20/i)
      page.should have_content(/Promotion \(Promo\)\s\-\$5.00/i)
      expect(page).to have_content(/Order Total:\s\$15/i)
      fill_in_address(test_case_3_address)
      click_button 'Save and Continue'

      expect(page).not_to have_content(/Address Verification Failed/i)
      click_button 'Save and Continue'

      expect(page).to have_content(/Sales Tax\s\$1.29/i)
      expect(page).to have_content(/Order Total:\s\$36.29/i)
    end

    it 'TaxCloud Test Case 6, with shipping promotion' do
      add_to_cart('Shirt')
      click_button 'Checkout'
      fill_in 'order_email', with: 'test@example.com'
      click_button 'Continue'

      expect(page).to have_content(/Item Total:\s\$10/i)

      fill_in_address(test_case_6_address)
      click_button 'Save and Continue'

      expect(page).to have_content(/Sales Tax\s\$1.78/i)
      expect(page).to have_content(/Order Total:\s\$21.78/i)
      expect(page).to_not have_content(/Address Verification Failed/i)

      click_button 'Save and Continue'

      expect(page).to have_content(/Sales Tax\s\$1.78/i)
      expect(page).to have_content(/Order Total:\s\$21.78/i)

      fill_in 'Coupon Code', with: 'BBBB'
      click_button 'Save and Continue'

      expect(page).to have_content(/Sales Tax\s\$0.89/i)
      expect(page).to have_content(/Order Total:\s\$10.89/i)

      click_button 'Place Order'

      expect(current_path).to match(spree.order_path(Spree::Order.last))

      # $10 price + $10 shipping - $10 shipping promo + $0.89 tax
      expect(page).to have_content(/Sales Tax\s\$0.89/i)
      expect(page).to have_content(/ORDER TOTAL:\s\$10.89/i)
    end
  end

  def add_to_cart(item_name)
    visit spree.products_path
    click_link item_name
    click_button 'add-to-cart-button'
  end

  def fill_in_address(address)
    fieldname = 'order_bill_address_attributes'
    fill_in "#{fieldname}_firstname", with: address.first_name
    fill_in "#{fieldname}_lastname", with: address.last_name
    fill_in "#{fieldname}_address1", with: address.address1
    fill_in "#{fieldname}_city", with: address.city
    select address.country.name, from: "#{fieldname}_country_id"

    # Wait for the ajax to complete for the states selector.
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        break if page.evaluate_script('jQuery.active').to_i == 0
      end
    end

    if !address.state.nil?
      select address.state.name, from: "#{fieldname}_state_id"
    else
      expect(page).not_to have_css("##{fieldname}_state_id.required")
    end
    fill_in "#{fieldname}_zipcode", with: address.zipcode
    fill_in "#{fieldname}_phone", with: address.phone
  end

  def stock_location_address
    Spree::Address.new(
      firstname: 'Testing',
      lastname: 'Location',
      address1: '3121 W Government Way',
      city: 'Seattle',
      country: Spree::Country.find_by(name: 'United States of America'),
      state: Spree::State.find_by(abbr: 'WA'),
      zipcode: '98199-1402',
      phone: '(555) 5555-555'
    )
  end

  def test_case_1a_address
    Spree::Address.new(
      firstname: 'John',
      lastname: 'Doe',
      address1: '1 3rd Street',
      city: 'Seattle',
      country: Spree::Country.find_by(name: 'United States of America'),
      state: Spree::State.find_by(abbr: 'WA'),
      zipcode: '98001',
      phone: '(555) 5555-555'
    )
  end

  def test_case_1b_address
    Spree::Address.new(
      firstname: 'John',
      lastname: 'Doe',
      address1: '16422 SE 128th St',
      city: 'Renton',
      country: Spree::Country.find_by(name: 'United States of America'),
      state: Spree::State.find_by(abbr: 'WA'),
      zipcode: '98059',
      phone: '(555) 5555-555'
    )
  end

  def test_case_2a_address
    Spree::Address.new(
      firstname: 'John',
      lastname: 'Doe',
      address1: '75 Rev Martin Luther King Jr Drive',
      city: 'St. Paul',
      country: Spree::Country.find_by(name: 'United States of America'),
      state: Spree::State.find_by(abbr: 'MN'),
      zipcode: '55155',
      phone: '(555) 5555-555'
    )
  end
  alias_method :test_case_2b_address, :test_case_2a_address

  def test_case_3_address
    Spree::Address.new(
      firstname: 'John',
      lastname: 'Doe',
      address1: '2300 N Lincoln Blvd',
      city: 'Oklahoma City',
      country: Spree::Country.where(name: 'United States of America').first,
      state: Spree::State.where(abbr: 'OK').first,
      zipcode: '73105',
      phone: '(555) 5555-555'
    )
  end

  def test_case_6_address
    Spree::Address.new(
      firstname: 'John',
      lastname: 'Doe',
      address1: '384 Northyards Blvd NW',
      city: 'Atlanta',
      country: Spree::Country.where(name: 'United States of America').first,
      state: Spree::State.where(abbr: 'GA').first,
      zipcode: '30313',
      phone: '(555) 5555-555'
    )
  end

  def alabama_address
    alabama_address = Spree::Address.new(
      firstname: 'John',
      lastname: 'Doe',
      address1: '143 Swan Street',
      city: 'Montgomery',
      country: Spree::Country.where(name: 'United States of America').first,
      state: Spree::State.where(name: 'Alabama').first,
      zipcode: '36110',
      phone: '(555) 5555-555'
    )
  end
end
