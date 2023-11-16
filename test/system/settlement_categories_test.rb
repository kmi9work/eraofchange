require "application_system_test_case"

class SettlementCategoriesTest < ApplicationSystemTestCase
  setup do
    @settlement_category = settlement_categories(:one)
  end

  test "visiting the index" do
    visit settlement_categories_url
    assert_selector "h1", text: "Settlement categories"
  end

  test "should create settlement category" do
    visit settlement_categories_url
    click_on "New settlement category"

    click_on "Create Settlement category"

    assert_text "Settlement category was successfully created"
    click_on "Back"
  end

  test "should update Settlement category" do
    visit settlement_category_url(@settlement_category)
    click_on "Edit this settlement category", match: :first

    click_on "Update Settlement category"

    assert_text "Settlement category was successfully updated"
    click_on "Back"
  end

  test "should destroy Settlement category" do
    visit settlement_category_url(@settlement_category)
    click_on "Destroy this settlement category", match: :first

    assert_text "Settlement category was successfully destroyed"
  end
end
