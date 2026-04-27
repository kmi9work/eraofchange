require "application_system_test_case"

class PlantTypesTest < ApplicationSystemTestCase
  setup do
    @plant_type = plant_types(:one)
  end

  test "visiting the index" do
    visit plant_types_url
    assert_selector "h1", text: "Plant types"
  end

  test "should create plant type" do
    visit plant_types_url
    click_on "New plant type"

    click_on "Create Plant type"

    assert_text "Plant type was successfully created"
    click_on "Back"
  end

  test "should update Plant type" do
    visit plant_type_url(@plant_type)
    click_on "Edit this plant type", match: :first

    click_on "Update Plant type"

    assert_text "Plant type was successfully updated"
    click_on "Back"
  end

  test "should destroy Plant type" do
    visit plant_type_url(@plant_type)
    click_on "Destroy this plant type", match: :first

    assert_text "Plant type was successfully destroyed"
  end
end
