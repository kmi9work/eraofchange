require "test_helper"

class InfluenceItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @influence_item = influence_items(:one)
  end

  test "should get index" do
    get influence_items_url
    assert_response :success
  end

  test "should get new" do
    get new_influence_item_url
    assert_response :success
  end

  test "should create influence_item" do
    assert_difference("InfluenceItem.count") do
      post influence_items_url, params: { influence_item: { comment: @influence_item.comment, entity_id: @influence_item.entity_id, entity_type: @influence_item.entity_type, player_id: @influence_item.player_id, value: @influence_item.value, year: @influence_item.year } }
    end

    assert_redirected_to influence_item_url(InfluenceItem.last)
  end

  test "should show influence_item" do
    get influence_item_url(@influence_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_influence_item_url(@influence_item)
    assert_response :success
  end

  test "should update influence_item" do
    patch influence_item_url(@influence_item), params: { influence_item: { comment: @influence_item.comment, entity_id: @influence_item.entity_id, entity_type: @influence_item.entity_type, player_id: @influence_item.player_id, value: @influence_item.value, year: @influence_item.year } }
    assert_redirected_to influence_item_url(@influence_item)
  end

  test "should destroy influence_item" do
    assert_difference("InfluenceItem.count", -1) do
      delete influence_item_url(@influence_item)
    end

    assert_redirected_to influence_items_url
  end
end
