require "application_system_test_case"

class TroopsTest < ApplicationSystemTestCase
  setup do
    @troop = troops(:one)
  end

  test "visiting the index" do
    visit troops_url
    assert_selector "h1", text: "Troops"
  end

  test "should create troop" do
    visit troops_url
    click_on "New troop"

    fill_in "Army", with: @troop.army_id
    check "Is hired" if @troop.is_hired
    fill_in "Troop type", with: @troop.troop_type_id
    click_on "Create Troop"

    assert_text "Troop was successfully created"
    click_on "Back"
  end

  test "should update Troop" do
    visit troop_url(@troop)
    click_on "Edit this troop", match: :first

    fill_in "Army", with: @troop.army_id
    check "Is hired" if @troop.is_hired
    fill_in "Troop type", with: @troop.troop_type_id
    click_on "Update Troop"

    assert_text "Troop was successfully updated"
    click_on "Back"
  end

  test "should destroy Troop" do
    visit troop_url(@troop)
    click_on "Destroy this troop", match: :first

    assert_text "Troop was successfully destroyed"
  end
end
