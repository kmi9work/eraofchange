require "test_helper"

class PublicOrderItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @public_order_item = public_order_items(:one)
  end

  test "should get index" do
    get public_order_items_url
    assert_response :success
  end

  test "should get new" do
    get new_public_order_item_url
    assert_response :success
  end

  test "should create public_order_item" do
    assert_difference("PublicOrderItem.count") do
      post public_order_items_url, params: { public_order_item: { comment: @public_order_item.comment, entity_id: @public_order_item.entity_id, entity_type: @public_order_item.entity_type, region_id: @public_order_item.region_id, value: @public_order_item.value, year: @public_order_item.year } }
    end

    assert_redirected_to public_order_item_url(PublicOrderItem.last)
  end

  test "should show public_order_item" do
    get public_order_item_url(@public_order_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_public_order_item_url(@public_order_item)
    assert_response :success
  end

  test "should update public_order_item" do
    patch public_order_item_url(@public_order_item), params: { public_order_item: { comment: @public_order_item.comment, entity_id: @public_order_item.entity_id, entity_type: @public_order_item.entity_type, region_id: @public_order_item.region_id, value: @public_order_item.value, year: @public_order_item.year } }
    assert_redirected_to public_order_item_url(@public_order_item)
  end

  test "should destroy public_order_item" do
    assert_difference("PublicOrderItem.count", -1) do
      delete public_order_item_url(@public_order_item)
    end

    assert_redirected_to public_order_items_url
  end
end
