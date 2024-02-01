require "application_system_test_case"

class PlayerTypesTest < ApplicationSystemTestCase
  setup do
    @player_type = player_types(:one)
  end

  test "visiting the index" do
    visit player_types_url
    assert_selector "h1", text: "Player types"
  end

  test "should create player type" do
    visit player_types_url
    click_on "New player type"

    fill_in "Ideologist type", with: @player_type.ideologist_type_id
    fill_in "Title", with: @player_type.title
    click_on "Create Player type"

    assert_text "Player type was successfully created"
    click_on "Back"
  end

  test "should update Player type" do
    visit player_type_url(@player_type)
    click_on "Edit this player type", match: :first

    fill_in "Ideologist type", with: @player_type.ideologist_type_id
    fill_in "Title", with: @player_type.title
    click_on "Update Player type"

    assert_text "Player type was successfully updated"
    click_on "Back"
  end

  test "should destroy Player type" do
    visit player_type_url(@player_type)
    click_on "Destroy this player type", match: :first

    assert_text "Player type was successfully destroyed"
  end
end
