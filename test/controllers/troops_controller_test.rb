require "test_helper"

class TroopsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @troop = troops(:one)
  end

  test "should get index" do
    get troops_url
    assert_response :success
  end

  test "should get new" do
    get new_troop_url
    assert_response :success
  end

  test "should create troop" do
    assert_difference("Troop.count") do
      post troops_url, params: { troop: { army_id: @troop.army_id, is_hired: @troop.is_hired, troop_type_id: @troop.troop_type_id } }
    end

    assert_redirected_to troop_url(Troop.last)
  end

  test "should show troop" do
    get troop_url(@troop)
    assert_response :success
  end

  test "should get edit" do
    get edit_troop_url(@troop)
    assert_response :success
  end

  test "should update troop" do
    patch troop_url(@troop), params: { troop: { army_id: @troop.army_id, is_hired: @troop.is_hired, troop_type_id: @troop.troop_type_id } }
    assert_redirected_to troop_url(@troop)
  end

  test "should destroy troop" do
    assert_difference("Troop.count", -1) do
      delete troop_url(@troop)
    end

    assert_redirected_to troops_url
  end
end
