require "test_helper"

class TechnologyItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @technology_item = technology_items(:one)
  end

  test "should get index" do
    get technology_items_url
    assert_response :success
  end

  test "should get new" do
    get new_technology_item_url
    assert_response :success
  end

  test "should create technology_item" do
    assert_difference("TechnologyItem.count") do
      post technology_items_url, params: { technology_item: { comment: @technology_item.comment, entity_id: @technology_item.entity_id, entity_type: @technology_item.entity_type, technology_id: @technology_item.technology_id, value: @technology_item.value, year: @technology_item.year } }
    end

    assert_redirected_to technology_item_url(TechnologyItem.last)
  end

  test "should show technology_item" do
    get technology_item_url(@technology_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_technology_item_url(@technology_item)
    assert_response :success
  end

  test "should update technology_item" do
    patch technology_item_url(@technology_item), params: { technology_item: { comment: @technology_item.comment, entity_id: @technology_item.entity_id, entity_type: @technology_item.entity_type, technology_id: @technology_item.technology_id, value: @technology_item.value, year: @technology_item.year } }
    assert_redirected_to technology_item_url(@technology_item)
  end

  test "should destroy technology_item" do
    assert_difference("TechnologyItem.count", -1) do
      delete technology_item_url(@technology_item)
    end

    assert_redirected_to technology_items_url
  end
end
