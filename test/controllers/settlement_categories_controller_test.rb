require "test_helper"

class SettlementCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @settlement_category = settlement_categories(:one)
  end

  test "should get index" do
    get settlement_categories_url
    assert_response :success
  end

  test "should get new" do
    get new_settlement_category_url
    assert_response :success
  end

  test "should create settlement_category" do
    assert_difference("SettlementCategory.count") do
      post settlement_categories_url, params: { settlement_category: {  } }
    end

    assert_redirected_to settlement_category_url(SettlementCategory.last)
  end

  test "should show settlement_category" do
    get settlement_category_url(@settlement_category)
    assert_response :success
  end

  test "should get edit" do
    get edit_settlement_category_url(@settlement_category)
    assert_response :success
  end

  test "should update settlement_category" do
    patch settlement_category_url(@settlement_category), params: { settlement_category: {  } }
    assert_redirected_to settlement_category_url(@settlement_category)
  end

  test "should destroy settlement_category" do
    assert_difference("SettlementCategory.count", -1) do
      delete settlement_category_url(@settlement_category)
    end

    assert_redirected_to settlement_categories_url
  end
end
