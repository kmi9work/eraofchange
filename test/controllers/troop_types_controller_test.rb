require "test_helper"

class TroopTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @troop_type = troop_types(:one)
  end

  test "should get index" do
    get troop_types_url
    assert_response :success
  end

  test "should get new" do
    get new_troop_type_url
    assert_response :success
  end

  test "should create troop_type" do
    assert_difference("TroopType.count") do
      post troop_types_url, params: { troop_type: { params: @troop_type.params, name: @troop_type.name } }
    end

    assert_redirected_to troop_type_url(TroopType.last)
  end

  test "should show troop_type" do
    get troop_type_url(@troop_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_troop_type_url(@troop_type)
    assert_response :success
  end

  test "should update troop_type" do
    patch troop_type_url(@troop_type), params: { troop_type: { params: @troop_type.params, name: @troop_type.name } }
    assert_redirected_to troop_type_url(@troop_type)
  end

  test "should destroy troop_type" do
    assert_difference("TroopType.count", -1) do
      delete troop_type_url(@troop_type)
    end

    assert_redirected_to troop_types_url
  end
end
