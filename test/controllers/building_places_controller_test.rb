require "test_helper"

class BuildingPlacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @building_place = building_places(:one)
  end

  test "should get index" do
    get building_places_url
    assert_response :success
  end

  test "should get new" do
    get new_building_place_url
    assert_response :success
  end

  test "should create building_place" do
    assert_difference("BuildingPlace.count") do
      post building_places_url, params: { building_place: { category: @building_place.category, params: @building_place.params } }
    end

    assert_redirected_to building_place_url(BuildingPlace.last)
  end

  test "should show building_place" do
    get building_place_url(@building_place)
    assert_response :success
  end

  test "should get edit" do
    get edit_building_place_url(@building_place)
    assert_response :success
  end

  test "should update building_place" do
    patch building_place_url(@building_place), params: { building_place: { category: @building_place.category, params: @building_place.params } }
    assert_redirected_to building_place_url(@building_place)
  end

  test "should destroy building_place" do
    assert_difference("BuildingPlace.count", -1) do
      delete building_place_url(@building_place)
    end

    assert_redirected_to building_places_url
  end
end
