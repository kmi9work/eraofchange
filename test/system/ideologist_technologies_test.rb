require "application_system_test_case"

class IdeologistTechnologiesTest < ApplicationSystemTestCase
  setup do
    @technology = technologies(:one)
  end

  test "visiting the index" do
    visit technologies_url
    assert_selector "h1", text: "Ideologist technologies"
  end

  test "should create ideologist technology" do
    visit technologies_url
    click_on "New ideologist technology"

    fill_in "Ideologist type", with: @technology.ideologist_type_id
    fill_in "Params", with: @technology.params
    fill_in "Requirements", with: @technology.requirements
    fill_in "name", with: @technology.name
    click_on "Create Ideologist technology"

    assert_text "Ideologist technology was successfully created"
    click_on "Back"
  end

  test "should update Ideologist technology" do
    visit technology_url(@technology)
    click_on "Edit this ideologist technology", match: :first

    fill_in "Ideologist type", with: @technology.ideologist_type_id
    fill_in "Params", with: @technology.params
    fill_in "Requirements", with: @technology.requirements
    fill_in "name", with: @technology.name
    click_on "Update Ideologist technology"

    assert_text "Ideologist technology was successfully updated"
    click_on "Back"
  end

  test "should destroy Ideologist technology" do
    visit technology_url(@technology)
    click_on "Destroy this ideologist technology", match: :first

    assert_text "Ideologist technology was successfully destroyed"
  end
end
