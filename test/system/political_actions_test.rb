require "application_system_test_case"

class PoliticalActionsTest < ApplicationSystemTestCase
  setup do
    @political_action = political_actions(:one)
  end

  test "visiting the index" do
    visit political_actions_url
    assert_selector "h1", text: "Political actions"
  end

  test "should create political action" do
    visit political_actions_url
    click_on "New political action"

    fill_in "Params", with: @political_action.params
    fill_in "Player", with: @political_action.player_id
    fill_in "Political action type", with: @political_action.political_action_type_id
    fill_in "Success", with: @political_action.success
    fill_in "Year", with: @political_action.year
    click_on "Create Political action"

    assert_text "Political action was successfully created"
    click_on "Back"
  end

  test "should update Political action" do
    visit political_action_url(@political_action)
    click_on "Edit this political action", match: :first

    fill_in "Params", with: @political_action.params
    fill_in "Player", with: @political_action.player_id
    fill_in "Political action type", with: @political_action.political_action_type_id
    fill_in "Success", with: @political_action.success
    fill_in "Year", with: @political_action.year
    click_on "Update Political action"

    assert_text "Political action was successfully updated"
    click_on "Back"
  end

  test "should destroy Political action" do
    visit political_action_url(@political_action)
    click_on "Destroy this political action", match: :first

    assert_text "Political action was successfully destroyed"
  end
end
