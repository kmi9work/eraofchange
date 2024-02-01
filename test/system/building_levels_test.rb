require "application_system_test_case"

class BuildingLevelsTest < ApplicationSystemTestCase
  setup do
    @building_level = building_levels(:one)
  end

  test "visiting the index" do
    visit building_levels_url
    assert_selector "h1", text: "Building levels"
  end

  test "should create building level" do
    visit building_levels_url
    click_on "New building level"

    fill_in "Building type", with: @building_level.building_type_id
    fill_in "Level", with: @building_level.level
    fill_in "Params", with: @building_level.params
    fill_in "Price", with: @building_level.price
    click_on "Create Building level"

    assert_text "Building level was successfully created"
    click_on "Back"
  end

  test "should update Building level" do
    visit building_level_url(@building_level)
    click_on "Edit this building level", match: :first

    fill_in "Building type", with: @building_level.building_type_id
    fill_in "Level", with: @building_level.level
    fill_in "Params", with: @building_level.params
    fill_in "Price", with: @building_level.price
    click_on "Update Building level"

    assert_text "Building level was successfully updated"
    click_on "Back"
  end

  test "should destroy Building level" do
    visit building_level_url(@building_level)
    click_on "Destroy this building level", match: :first

    assert_text "Building level was successfully destroyed"
  end
end
