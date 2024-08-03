require "test_helper"

class GameparametersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @gameparameter = gameparameters(:one)
  end

  test "should get index" do
    get gameparameters_url
    assert_response :success
  end

  test "should get new" do
    get new_gameparameter_url
    assert_response :success
  end

  test "should create gameparameter" do
    assert_difference("Gameparameter.count") do
      post gameparameters_url, params: { gameparameter: {  } }
    end

    assert_redirected_to gameparameter_url(Gameparameter.last)
  end

  test "should show gameparameter" do
    get gameparameter_url(@gameparameter)
    assert_response :success
  end

  test "should get edit" do
    get edit_gameparameter_url(@gameparameter)
    assert_response :success
  end

  test "should update gameparameter" do
    patch gameparameter_url(@gameparameter), params: { gameparameter: {  } }
    assert_redirected_to gameparameter_url(@gameparameter)
  end

  test "should destroy gameparameter" do
    assert_difference("Gameparameter.count", -1) do
      delete gameparameter_url(@gameparameter)
    end

    assert_redirected_to gameparameters_url
  end
end
