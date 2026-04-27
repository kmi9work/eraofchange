require "application_system_test_case"

class CaravansTest < ApplicationSystemTestCase
  setup do
    @caravan = caravans(:one)
  end

  test "visiting the index" do
    visit caravans_url
    assert_selector "h1", text: "Caravans"
  end

  test "should create caravan" do
    visit caravans_url
    click_on "New caravan"

    fill_in "Body", with: @caravan.body
    fill_in "Title", with: @caravan.title
    click_on "Create Caravan"

    assert_text "Caravan was successfully created"
    click_on "Back"
  end

  test "should update Caravan" do
    visit caravan_url(@caravan)
    click_on "Edit this caravan", match: :first

    fill_in "Body", with: @caravan.body
    fill_in "Title", with: @caravan.title
    click_on "Update Caravan"

    assert_text "Caravan was successfully updated"
    click_on "Back"
  end

  test "should destroy Caravan" do
    visit caravan_url(@caravan)
    click_on "Destroy this caravan", match: :first

    assert_text "Caravan was successfully destroyed"
  end
end
