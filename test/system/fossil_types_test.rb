require "application_system_test_case"

class FossilTypesTest < ApplicationSystemTestCase
  setup do
    @fossil_type = fossil_types(:one)
  end

  test "visiting the index" do
    visit fossil_types_url
    assert_selector "h1", text: "Fossil types"
  end

  test "should create fossil type" do
    visit fossil_types_url
    click_on "New fossil type"

    fill_in "Title", with: @fossil_type.title
    click_on "Create Fossil type"

    assert_text "Fossil type was successfully created"
    click_on "Back"
  end

  test "should update Fossil type" do
    visit fossil_type_url(@fossil_type)
    click_on "Edit this fossil type", match: :first

    fill_in "Title", with: @fossil_type.title
    click_on "Update Fossil type"

    assert_text "Fossil type was successfully updated"
    click_on "Back"
  end

  test "should destroy Fossil type" do
    visit fossil_type_url(@fossil_type)
    click_on "Destroy this fossil type", match: :first

    assert_text "Fossil type was successfully destroyed"
  end
end
