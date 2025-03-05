require "application_system_test_case"

class TroopTypesTest < ApplicationSystemTestCase
  setup do
    @troop_type = troop_types(:one)
  end

  test "visiting the index" do
    visit troop_types_url
    assert_selector "h1", text: "Troop types"
  end

  test "should create troop type" do
    visit troop_types_url
    click_on "New troop type"

    fill_in "Params", with: @troop_type.params
    fill_in "name", with: @troop_type.name
    click_on "Create Troop type"

    assert_text "Troop type was successfully created"
    click_on "Back"
  end

  test "should update Troop type" do
    visit troop_type_url(@troop_type)
    click_on "Edit this troop type", match: :first

    fill_in "Params", with: @troop_type.params
    fill_in "name", with: @troop_type.name
    click_on "Update Troop type"

    assert_text "Troop type was successfully updated"
    click_on "Back"
  end

  test "should destroy Troop type" do
    visit troop_type_url(@troop_type)
    click_on "Destroy this troop type", match: :first

    assert_text "Troop type was successfully destroyed"
  end
end
