require "application_system_test_case"

class BuildingPlacesTest < ApplicationSystemTestCase
  setup do
    @building_place = building_places(:one)
  end

  test "visiting the index" do
    visit building_places_url
    assert_selector "h1", text: "Building places"
  end

  test "should create building place" do
    visit building_places_url
    click_on "New building place"

    fill_in "Category", with: @building_place.category
    fill_in "Params", with: @building_place.params
    click_on "Create Building place"

    assert_text "Building place was successfully created"
    click_on "Back"
  end

  test "should update Building place" do
    visit building_place_url(@building_place)
    click_on "Edit this building place", match: :first

    fill_in "Category", with: @building_place.category
    fill_in "Params", with: @building_place.params
    click_on "Update Building place"

    assert_text "Building place was successfully updated"
    click_on "Back"
  end

  test "should destroy Building place" do
    visit building_place_url(@building_place)
    click_on "Destroy this building place", match: :first

    assert_text "Building place was successfully destroyed"
  end
end
