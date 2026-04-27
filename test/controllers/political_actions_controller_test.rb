require "test_helper"

class PoliticalActionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @political_action = political_actions(:one)
  end

  test "should get index" do
    get political_actions_url
    assert_response :success
  end

  test "should get new" do
    get new_political_action_url
    assert_response :success
  end

  test "should create political_action" do
    assert_difference("PoliticalAction.count") do
      post political_actions_url, params: { political_action: { params: @political_action.params, player_id: @political_action.player_id, political_action_type_id: @political_action.political_action_type_id, success: @political_action.success, year: @political_action.year } }
    end

    assert_redirected_to political_action_url(PoliticalAction.last)
  end

  test "should show political_action" do
    get political_action_url(@political_action)
    assert_response :success
  end

  test "should get edit" do
    get edit_political_action_url(@political_action)
    assert_response :success
  end

  test "should update political_action" do
    patch political_action_url(@political_action), params: { political_action: { params: @political_action.params, player_id: @political_action.player_id, political_action_type_id: @political_action.political_action_type_id, success: @political_action.success, year: @political_action.year } }
    assert_redirected_to political_action_url(@political_action)
  end

  test "should destroy political_action" do
    assert_difference("PoliticalAction.count", -1) do
      delete political_action_url(@political_action)
    end

    assert_redirected_to political_actions_url
  end
end
