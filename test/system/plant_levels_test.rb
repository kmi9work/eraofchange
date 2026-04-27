require "application_system_test_case"

class PlantLevelsTest < ApplicationSystemTestCase
  setup do
    @plant_level = plant_levels(:one)
  end

  test "visiting the index" do
    visit plant_levels_url
    assert_selector "h1", text: "Plant levels"
  end

  test "should create plant level" do
    visit plant_levels_url
    click_on "New plant level"

    fill_in "Charge", with: @plant_level.charge
    fill_in "Deposit", with: @plant_level.deposit
    fill_in "Formula", with: @plant_level.formula
    fill_in "Level", with: @plant_level.level
    fill_in "Max product", with: @plant_level.max_product
    fill_in "Price", with: @plant_level.price
    click_on "Create Plant level"

    assert_text "Plant level was successfully created"
    click_on "Back"
  end

  test "should update Plant level" do
    visit plant_level_url(@plant_level)
    click_on "Edit this plant level", match: :first

    fill_in "Charge", with: @plant_level.charge
    fill_in "Deposit", with: @plant_level.deposit
    fill_in "Formula", with: @plant_level.formula
    fill_in "Level", with: @plant_level.level
    fill_in "Max product", with: @plant_level.max_product
    fill_in "Price", with: @plant_level.price
    click_on "Update Plant level"

    assert_text "Plant level was successfully updated"
    click_on "Back"
  end

  test "should destroy Plant level" do
    visit plant_level_url(@plant_level)
    click_on "Destroy this plant level", match: :first

    assert_text "Plant level was successfully destroyed"
  end
end
