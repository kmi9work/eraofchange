require "application_system_test_case"

class BuildingTypesTest < ApplicationSystemTestCase
  setup do
    @building_type = building_types(:one)
  end

  test "visiting the index" do
    visit building_types_url
    assert_selector "h1", text: "Building types"
  end

  test "should create building type" do
    visit building_types_url
    click_on "New building type"

    fill_in "Params", with: @building_type.params
    fill_in "name", with: @building_type.name
    click_on "Create Building type"

    assert_text "Building type was successfully created"
    click_on "Back"
  end

  test "should update Building type" do
    visit building_type_url(@building_type)
    click_on "Edit this building type", match: :first

    fill_in "Params", with: @building_type.params
    fill_in "name", with: @building_type.name
    click_on "Update Building type"

    assert_text "Building type was successfully updated"
    click_on "Back"
  end

  test "should destroy Building type" do
    visit building_type_url(@building_type)
    click_on "Destroy this building type", match: :first

    assert_text "Building type was successfully destroyed"
  end
end
