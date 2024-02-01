require "application_system_test_case"

class ArmySizesTest < ApplicationSystemTestCase
  setup do
    @army_size = army_sizes(:one)
  end

  test "visiting the index" do
    visit army_sizes_url
    assert_selector "h1", text: "Army sizes"
  end

  test "should create army size" do
    visit army_sizes_url
    click_on "New army size"

    fill_in "Level", with: @army_size.level
    fill_in "Params", with: @army_size.params
    click_on "Create Army size"

    assert_text "Army size was successfully created"
    click_on "Back"
  end

  test "should update Army size" do
    visit army_size_url(@army_size)
    click_on "Edit this army size", match: :first

    fill_in "Level", with: @army_size.level
    fill_in "Params", with: @army_size.params
    click_on "Update Army size"

    assert_text "Army size was successfully updated"
    click_on "Back"
  end

  test "should destroy Army size" do
    visit army_size_url(@army_size)
    click_on "Destroy this army size", match: :first

    assert_text "Army size was successfully destroyed"
  end
end
