require "application_system_test_case"

class GuildsTest < ApplicationSystemTestCase
  setup do
    @guild = guilds(:one)
  end

  test "visiting the index" do
    visit guilds_url
    assert_selector "h1", text: "Guilds"
  end

  test "should create guild" do
    visit guilds_url
    click_on "New guild"

    click_on "Create Guild"

    assert_text "Guild was successfully created"
    click_on "Back"
  end

  test "should update Guild" do
    visit guild_url(@guild)
    click_on "Edit this guild", match: :first

    click_on "Update Guild"

    assert_text "Guild was successfully updated"
    click_on "Back"
  end

  test "should destroy Guild" do
    visit guild_url(@guild)
    click_on "Destroy this guild", match: :first

    assert_text "Guild was successfully destroyed"
  end
end
