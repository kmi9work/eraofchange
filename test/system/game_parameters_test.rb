require "application_system_test_case"

class GameParametersTest < ApplicationSystemTestCase
  setup do
    @game_parameter = game_parameters(:one)
  end

  test "visiting the index" do
    visit game_parameters_url
    assert_selector "h1", text: "Game parameters"
  end

  test "should create game parameter" do
    visit game_parameters_url
    click_on "New game parameter"

    click_on "Create Game parameter"

    assert_text "Game parameter was successfully created"
    click_on "Back"
  end

  test "should update Game parameter" do
    visit game_parameter_url(@game_parameter)
    click_on "Edit this game parameter", match: :first

    click_on "Update Game parameter"

    assert_text "Game parameter was successfully updated"
    click_on "Back"
  end

  test "should destroy Game parameter" do
    visit game_parameter_url(@game_parameter)
    click_on "Destroy this game parameter", match: :first

    assert_text "Game parameter was successfully destroyed"
  end
end
