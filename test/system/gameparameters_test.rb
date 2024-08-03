require "application_system_test_case"

class GameParametersTest < ApplicationSystemTestCase
  setup do
    @GameParameter = GameParameters(:one)
  end

  test "visiting the index" do
    visit GameParameters_url
    assert_selector "h1", text: "GameParameters"
  end

  test "should create GameParameter" do
    visit GameParameters_url
    click_on "New GameParameter"

    click_on "Create GameParameter"

    assert_text "GameParameter was successfully created"
    click_on "Back"
  end

  test "should update GameParameter" do
    visit GameParameter_url(@GameParameter)
    click_on "Edit this GameParameter", match: :first

    click_on "Update GameParameter"

    assert_text "GameParameter was successfully updated"
    click_on "Back"
  end

  test "should destroy GameParameter" do
    visit GameParameter_url(@GameParameter)
    click_on "Destroy this GameParameter", match: :first

    assert_text "GameParameter was successfully destroyed"
  end
end
