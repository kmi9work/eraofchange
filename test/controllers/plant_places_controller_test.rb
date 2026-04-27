require "test_helper"

class PlantPlacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plant_place = plant_places(:one)
  end

  test "should get index" do
    get plant_places_url
    assert_response :success
  end

  test "should get new" do
    get new_plant_place_url
    assert_response :success
  end

  test "should create plant_place" do
    assert_difference("PlantPlace.count") do
      post plant_places_url, params: { plant_place: { plant_place_type: @plant_place.plant_place_type, name: @plant_place.name } }
    end

    assert_redirected_to plant_place_url(PlantPlace.last)
  end

  test "should show plant_place" do
    get plant_place_url(@plant_place)
    assert_response :success
  end

  test "should get edit" do
    get edit_plant_place_url(@plant_place)
    assert_response :success
  end

  test "should update plant_place" do
    patch plant_place_url(@plant_place), params: { plant_place: { plant_place_type: @plant_place.plant_place_type, name: @plant_place.name } }
    assert_redirected_to plant_place_url(@plant_place)
  end

  test "should destroy plant_place" do
    assert_difference("PlantPlace.count", -1) do
      delete plant_place_url(@plant_place)
    end

    assert_redirected_to plant_places_url
  end
end
