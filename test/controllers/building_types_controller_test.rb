require "test_helper"

class BuildingTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @building_type = building_types(:one)
  end

  test "should get index" do
    get building_types_url
    assert_response :success
  end

  test "should get new" do
    get new_building_type_url
    assert_response :success
  end

  test "should create building_type" do
    assert_difference("BuildingType.count") do
      post building_types_url, params: { building_type: { params: @building_type.params, name: @building_type.name } }
    end

    assert_redirected_to building_type_url(BuildingType.last)
  end

  test "should show building_type" do
    get building_type_url(@building_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_building_type_url(@building_type)
    assert_response :success
  end

  test "should update building_type" do
    patch building_type_url(@building_type), params: { building_type: { params: @building_type.params, name: @building_type.name } }
    assert_redirected_to building_type_url(@building_type)
  end

  test "should destroy building_type" do
    assert_difference("BuildingType.count", -1) do
      delete building_type_url(@building_type)
    end

    assert_redirected_to building_types_url
  end
end
