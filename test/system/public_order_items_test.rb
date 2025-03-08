require "application_system_test_case"

class PublicOrderItemsTest < ApplicationSystemTestCase
  setup do
    @public_order_item = public_order_items(:one)
  end

  test "visiting the index" do
    visit public_order_items_url
    assert_selector "h1", text: "Public order items"
  end

  test "should create public order item" do
    visit public_order_items_url
    click_on "New public order item"

    fill_in "Comment", with: @public_order_item.comment
    fill_in "Entity", with: @public_order_item.entity_id
    fill_in "Entity type", with: @public_order_item.entity_type
    fill_in "Region", with: @public_order_item.region_id
    fill_in "Value", with: @public_order_item.value
    fill_in "Year", with: @public_order_item.year
    click_on "Create Public order item"

    assert_text "Public order item was successfully created"
    click_on "Back"
  end

  test "should update Public order item" do
    visit public_order_item_url(@public_order_item)
    click_on "Edit this public order item", match: :first

    fill_in "Comment", with: @public_order_item.comment
    fill_in "Entity", with: @public_order_item.entity_id
    fill_in "Entity type", with: @public_order_item.entity_type
    fill_in "Region", with: @public_order_item.region_id
    fill_in "Value", with: @public_order_item.value
    fill_in "Year", with: @public_order_item.year
    click_on "Update Public order item"

    assert_text "Public order item was successfully updated"
    click_on "Back"
  end

  test "should destroy Public order item" do
    visit public_order_item_url(@public_order_item)
    click_on "Destroy this public order item", match: :first

    assert_text "Public order item was successfully destroyed"
  end
end
