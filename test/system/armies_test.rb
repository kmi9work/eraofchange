require "application_system_test_case"

class ArmiesTest < ApplicationSystemTestCase
  setup do
    @army = armies(:one)
  end

  test "visiting the index" do
    visit armies_url
    assert_selector "h1", text: "Armies"
  end

  test "should create army" do
    visit armies_url
    click_on "New army"

    fill_in "Army size", with: @army.army_size_id
    fill_in "Player", with: @army.player_id
    fill_in "Region", with: @army.region_id
    click_on "Create Army"

    assert_text "Army was successfully created"
    click_on "Back"
  end

  test "should update Army" do
    visit army_url(@army)
    click_on "Edit this army", match: :first

    fill_in "Army size", with: @army.army_size_id
    fill_in "Player", with: @army.player_id
    fill_in "Region", with: @army.region_id
    click_on "Update Army"

    assert_text "Army was successfully updated"
    click_on "Back"
  end

  test "should destroy Army" do
    visit army_url(@army)
    click_on "Destroy this army", match: :first

    assert_text "Army was successfully destroyed"
  end
end
