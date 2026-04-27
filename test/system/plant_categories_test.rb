require "application_system_test_case"

class PlantCategoriesTest < ApplicationSystemTestCase
  setup do
    @plant_category = plant_categories(:one)
  end

  test "visiting the index" do
    visit plant_categories_url
    assert_selector "h1", text: "Plant categories"
  end

  test "should create plant category" do
    visit plant_categories_url
    click_on "New plant category"

    click_on "Create Plant category"

    assert_text "Plant category was successfully created"
    click_on "Back"
  end

  test "should update Plant category" do
    visit plant_category_url(@plant_category)
    click_on "Edit this plant category", match: :first

    click_on "Update Plant category"

    assert_text "Plant category was successfully updated"
    click_on "Back"
  end

  test "should destroy Plant category" do
    visit plant_category_url(@plant_category)
    click_on "Destroy this plant category", match: :first

    assert_text "Plant category was successfully destroyed"
  end
end
