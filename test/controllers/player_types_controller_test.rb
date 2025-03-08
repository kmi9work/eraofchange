require "test_helper"

class PlayerTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @player_type = player_types(:one)
  end

  test "should get index" do
    get player_types_url
    assert_response :success
  end

  test "should get new" do
    get new_player_type_url
    assert_response :success
  end

  test "should create player_type" do
    assert_difference("PlayerType.count") do
      post player_types_url, params: { player_type: { ideologist_type_id: @player_type.ideologist_type_id, name: @player_type.name } }
    end

    assert_redirected_to player_type_url(PlayerType.last)
  end

  test "should show player_type" do
    get player_type_url(@player_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_player_type_url(@player_type)
    assert_response :success
  end

  test "should update player_type" do
    patch player_type_url(@player_type), params: { player_type: { ideologist_type_id: @player_type.ideologist_type_id, name: @player_type.name } }
    assert_redirected_to player_type_url(@player_type)
  end

  test "should destroy player_type" do
    assert_difference("PlayerType.count", -1) do
      delete player_type_url(@player_type)
    end

    assert_redirected_to player_types_url
  end
end
