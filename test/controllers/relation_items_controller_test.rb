require "test_helper"

class RelationItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @relation_item = relation_items(:one)
  end

  test "should get index" do
    get relation_items_url
    assert_response :success
  end

  test "should get new" do
    get new_relation_item_url
    assert_response :success
  end

  test "should create relation_item" do
    assert_difference("RelationItem.count") do
      post relation_items_url, params: { relation_item: { comment: @relation_item.comment, country_id: @relation_item.country_id, entity_id: @relation_item.entity_id, entity_type: @relation_item.entity_type, value: @relation_item.value, year: @relation_item.year } }
    end

    assert_redirected_to relation_item_url(RelationItem.last)
  end

  test "should show relation_item" do
    get relation_item_url(@relation_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_relation_item_url(@relation_item)
    assert_response :success
  end

  test "should update relation_item" do
    patch relation_item_url(@relation_item), params: { relation_item: { comment: @relation_item.comment, country_id: @relation_item.country_id, entity_id: @relation_item.entity_id, entity_type: @relation_item.entity_type, value: @relation_item.value, year: @relation_item.year } }
    assert_redirected_to relation_item_url(@relation_item)
  end

  test "should destroy relation_item" do
    assert_difference("RelationItem.count", -1) do
      delete relation_item_url(@relation_item)
    end

    assert_redirected_to relation_items_url
  end
end
