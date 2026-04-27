require "application_system_test_case"

class PlantPlacesTest < ApplicationSystemTestCase
  setup do
    @plant_place = plant_places(:one)
  end

  test "visiting the index" do
    visit plant_places_url
    assert_selector "h1", text: "Plant places"
  end

  test "should create plant place" do
    visit plant_places_url
    click_on "New plant place"

    fill_in "Plant place type", with: @plant_place.plant_place_type
    fill_in "name", with: @plant_place.name
    click_on "Create Plant place"

    assert_text "Plant place was successfully created"
    click_on "Back"
  end

  test "should update Plant place" do
    visit plant_place_url(@plant_place)
    click_on "Edit this plant place", match: :first

    fill_in "Plant place type", with: @plant_place.plant_place_type
    fill_in "name", with: @plant_place.name
    click_on "Update Plant place"

    assert_text "Plant place was successfully updated"
    click_on "Back"
  end

  test "should destroy Plant place" do
    visit plant_place_url(@plant_place)
    click_on "Destroy this plant place", match: :first

    assert_text "Plant place was successfully destroyed"
  end
end
