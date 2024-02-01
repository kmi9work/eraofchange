require "test_helper"

class ArmySizesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @army_size = army_sizes(:one)
  end

  test "should get index" do
    get army_sizes_url
    assert_response :success
  end

  test "should get new" do
    get new_army_size_url
    assert_response :success
  end

  test "should create army_size" do
    assert_difference("ArmySize.count") do
      post army_sizes_url, params: { army_size: { level: @army_size.level, params: @army_size.params } }
    end

    assert_redirected_to army_size_url(ArmySize.last)
  end

  test "should show army_size" do
    get army_size_url(@army_size)
    assert_response :success
  end

  test "should get edit" do
    get edit_army_size_url(@army_size)
    assert_response :success
  end

  test "should update army_size" do
    patch army_size_url(@army_size), params: { army_size: { level: @army_size.level, params: @army_size.params } }
    assert_redirected_to army_size_url(@army_size)
  end

  test "should destroy army_size" do
    assert_difference("ArmySize.count", -1) do
      delete army_size_url(@army_size)
    end

    assert_redirected_to army_sizes_url
  end
end
