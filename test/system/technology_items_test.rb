require "application_system_test_case"

class TechnologyItemsTest < ApplicationSystemTestCase
  setup do
    @technology_item = technology_items(:one)
  end

  test "visiting the index" do
    visit technology_items_url
    assert_selector "h1", text: "Technology items"
  end

  test "should create technology item" do
    visit technology_items_url
    click_on "New technology item"

    fill_in "Comment", with: @technology_item.comment
    fill_in "Entity", with: @technology_item.entity_id
    fill_in "Entity type", with: @technology_item.entity_type
    fill_in "Technology", with: @technology_item.technology_id
    fill_in "Value", with: @technology_item.value
    fill_in "Year", with: @technology_item.year
    click_on "Create Technology item"

    assert_text "Technology item was successfully created"
    click_on "Back"
  end

  test "should update Technology item" do
    visit technology_item_url(@technology_item)
    click_on "Edit this technology item", match: :first

    fill_in "Comment", with: @technology_item.comment
    fill_in "Entity", with: @technology_item.entity_id
    fill_in "Entity type", with: @technology_item.entity_type
    fill_in "Technology", with: @technology_item.technology_id
    fill_in "Value", with: @technology_item.value
    fill_in "Year", with: @technology_item.year
    click_on "Update Technology item"

    assert_text "Technology item was successfully updated"
    click_on "Back"
  end

  test "should destroy Technology item" do
    visit technology_item_url(@technology_item)
    click_on "Destroy this technology item", match: :first

    assert_text "Technology item was successfully destroyed"
  end
end
