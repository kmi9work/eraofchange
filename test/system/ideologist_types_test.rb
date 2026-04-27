require "application_system_test_case"

class IdeologistTypesTest < ApplicationSystemTestCase
  setup do
    @ideologist_type = ideologist_types(:one)
  end

  test "visiting the index" do
    visit ideologist_types_url
    assert_selector "h1", text: "Ideologist types"
  end

  test "should create ideologist type" do
    visit ideologist_types_url
    click_on "New ideologist type"

    fill_in "Name", with: @ideologist_type.name
    click_on "Create Ideologist type"

    assert_text "Ideologist type was successfully created"
    click_on "Back"
  end

  test "should update Ideologist type" do
    visit ideologist_type_url(@ideologist_type)
    click_on "Edit this ideologist type", match: :first

    fill_in "Name", with: @ideologist_type.name
    click_on "Update Ideologist type"

    assert_text "Ideologist type was successfully updated"
    click_on "Back"
  end

  test "should destroy Ideologist type" do
    visit ideologist_type_url(@ideologist_type)
    click_on "Destroy this ideologist type", match: :first

    assert_text "Ideologist type was successfully destroyed"
  end
end
