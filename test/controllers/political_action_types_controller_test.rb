require "test_helper"

class PoliticalActionTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @political_action_type = political_action_types(:one)
  end

  test "should get index" do
    get political_action_types_url
    assert_response :success
  end

  test "should get new" do
    get new_political_action_type_url
    assert_response :success
  end

  test "should create political_action_type" do
    assert_difference("PoliticalActionType.count") do
      post political_action_types_url, params: { political_action_type: { action: @political_action_type.action, params: @political_action_type.params, title: @political_action_type.title } }
    end

    assert_redirected_to political_action_type_url(PoliticalActionType.last)
  end

  test "should show political_action_type" do
    get political_action_type_url(@political_action_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_political_action_type_url(@political_action_type)
    assert_response :success
  end

  test "should update political_action_type" do
    patch political_action_type_url(@political_action_type), params: { political_action_type: { action: @political_action_type.action, params: @political_action_type.params, title: @political_action_type.title } }
    assert_redirected_to political_action_type_url(@political_action_type)
  end

  test "should destroy political_action_type" do
    assert_difference("PoliticalActionType.count", -1) do
      delete political_action_type_url(@political_action_type)
    end

    assert_redirected_to political_action_types_url
  end
end
