require "application_system_test_case"

class PoliticalActionTypesTest < ApplicationSystemTestCase
  setup do
    @political_action_type = political_action_types(:one)
  end

  test "visiting the index" do
    visit political_action_types_url
    assert_selector "h1", text: "Political action types"
  end

  test "should create political action type" do
    visit political_action_types_url
    click_on "New political action type"

    fill_in "Action", with: @political_action_type.action
    fill_in "Params", with: @political_action_type.params
    fill_in "Title", with: @political_action_type.title
    click_on "Create Political action type"

    assert_text "Political action type was successfully created"
    click_on "Back"
  end

  test "should update Political action type" do
    visit political_action_type_url(@political_action_type)
    click_on "Edit this political action type", match: :first

    fill_in "Action", with: @political_action_type.action
    fill_in "Params", with: @political_action_type.params
    fill_in "Title", with: @political_action_type.title
    click_on "Update Political action type"

    assert_text "Political action type was successfully updated"
    click_on "Back"
  end

  test "should destroy Political action type" do
    visit political_action_type_url(@political_action_type)
    click_on "Destroy this political action type", match: :first

    assert_text "Political action type was successfully destroyed"
  end
end
