require "application_system_test_case"

class IdeologistTechnologiesTest < ApplicationSystemTestCase
  setup do
    @ideologist_technology = ideologist_technologies(:one)
  end

  test "visiting the index" do
    visit ideologist_technologies_url
    assert_selector "h1", text: "Ideologist technologies"
  end

  test "should create ideologist technology" do
    visit ideologist_technologies_url
    click_on "New ideologist technology"

    fill_in "Ideologist type", with: @ideologist_technology.ideologist_type_id
    fill_in "Params", with: @ideologist_technology.params
    fill_in "Requirements", with: @ideologist_technology.requirements
    fill_in "Title", with: @ideologist_technology.title
    click_on "Create Ideologist technology"

    assert_text "Ideologist technology was successfully created"
    click_on "Back"
  end

  test "should update Ideologist technology" do
    visit ideologist_technology_url(@ideologist_technology)
    click_on "Edit this ideologist technology", match: :first

    fill_in "Ideologist type", with: @ideologist_technology.ideologist_type_id
    fill_in "Params", with: @ideologist_technology.params
    fill_in "Requirements", with: @ideologist_technology.requirements
    fill_in "Title", with: @ideologist_technology.title
    click_on "Update Ideologist technology"

    assert_text "Ideologist technology was successfully updated"
    click_on "Back"
  end

  test "should destroy Ideologist technology" do
    visit ideologist_technology_url(@ideologist_technology)
    click_on "Destroy this ideologist technology", match: :first

    assert_text "Ideologist technology was successfully destroyed"
  end
end
