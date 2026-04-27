require "test_helper"

class BuildingLevelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @building_level = building_levels(:one)
  end

  test "should get index" do
    get building_levels_url
    assert_response :success
  end

  test "should get new" do
    get new_building_level_url
    assert_response :success
  end

  test "should create building_level" do
    assert_difference("BuildingLevel.count") do
      post building_levels_url, params: { building_level: { building_type_id: @building_level.building_type_id, level: @building_level.level, params: @building_level.params, price: @building_level.price } }
    end

    assert_redirected_to building_level_url(BuildingLevel.last)
  end

  test "should show building_level" do
    get building_level_url(@building_level)
    assert_response :success
  end

  test "should get edit" do
    get edit_building_level_url(@building_level)
    assert_response :success
  end

  test "should update building_level" do
    patch building_level_url(@building_level), params: { building_level: { building_type_id: @building_level.building_type_id, level: @building_level.level, params: @building_level.params, price: @building_level.price } }
    assert_redirected_to building_level_url(@building_level)
  end

  test "should destroy building_level" do
    assert_difference("BuildingLevel.count", -1) do
      delete building_level_url(@building_level)
    end

    assert_redirected_to building_levels_url
  end
end
