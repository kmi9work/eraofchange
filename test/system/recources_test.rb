require "application_system_test_case"

class RecourcesTest < ApplicationSystemTestCase
  setup do
    @recource = recources(:one)
  end

  test "visiting the index" do
    visit recources_url
    assert_selector "h1", text: "Recources"
  end

  test "should create recource" do
    visit recources_url
    click_on "New recource"

    click_on "Create Recource"

    assert_text "Recource was successfully created"
    click_on "Back"
  end

  test "should update Recource" do
    visit recource_url(@recource)
    click_on "Edit this recource", match: :first

    click_on "Update Recource"

    assert_text "Recource was successfully updated"
    click_on "Back"
  end

  test "should destroy Recource" do
    visit recource_url(@recource)
    click_on "Destroy this recource", match: :first

    assert_text "Recource was successfully destroyed"
  end
end
