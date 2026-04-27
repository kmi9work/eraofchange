require "test_helper"

class GameParametersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game_parameter = game_parameters(:one)
  end

  test "should get index" do
    get game_parameters_url
    assert_response :success
  end

  test "should get new" do
    get new_game_parameter_url
    assert_response :success
  end

  test "should create game_parameter" do
    assert_difference("GameParameter.count") do
      post game_parameters_url, params: { game_parameter: {  } }
    end

    assert_redirected_to game_parameter_url(GameParameter.last)
  end

  test "should show game_parameter" do
    get game_parameter_url(@game_parameter)
    assert_response :success
  end

  test "should get edit" do
    get edit_game_parameter_url(@game_parameter)
    assert_response :success
  end

  test "should update game_parameter" do
    patch game_parameter_url(@game_parameter), params: { game_parameter: {  } }
    assert_redirected_to game_parameter_url(@game_parameter)
  end

  test "should destroy game_parameter" do
    assert_difference("GameParameter.count", -1) do
      delete game_parameter_url(@game_parameter)
    end

    assert_redirected_to game_parameters_url
  end
end
