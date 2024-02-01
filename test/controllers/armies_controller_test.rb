require "test_helper"

class ArmiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @army = armies(:one)
  end

  test "should get index" do
    get armies_url
    assert_response :success
  end

  test "should get new" do
    get new_army_url
    assert_response :success
  end

  test "should create army" do
    assert_difference("Army.count") do
      post armies_url, params: { army: { army_size_id: @army.army_size_id, player_id: @army.player_id, region_id: @army.region_id } }
    end

    assert_redirected_to army_url(Army.last)
  end

  test "should show army" do
    get army_url(@army)
    assert_response :success
  end

  test "should get edit" do
    get edit_army_url(@army)
    assert_response :success
  end

  test "should update army" do
    patch army_url(@army), params: { army: { army_size_id: @army.army_size_id, player_id: @army.player_id, region_id: @army.region_id } }
    assert_redirected_to army_url(@army)
  end

  test "should destroy army" do
    assert_difference("Army.count", -1) do
      delete army_url(@army)
    end

    assert_redirected_to armies_url
  end
end
