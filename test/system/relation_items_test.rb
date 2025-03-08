require "application_system_test_case"

class RelationItemsTest < ApplicationSystemTestCase
  setup do
    @relation_item = relation_items(:one)
  end

  test "visiting the index" do
    visit relation_items_url
    assert_selector "h1", text: "Relation items"
  end

  test "should create relation item" do
    visit relation_items_url
    click_on "New relation item"

    fill_in "Comment", with: @relation_item.comment
    fill_in "Country", with: @relation_item.country_id
    fill_in "Entity", with: @relation_item.entity_id
    fill_in "Entity type", with: @relation_item.entity_type
    fill_in "Value", with: @relation_item.value
    fill_in "Year", with: @relation_item.year
    click_on "Create Relation item"

    assert_text "Relation item was successfully created"
    click_on "Back"
  end

  test "should update Relation item" do
    visit relation_item_url(@relation_item)
    click_on "Edit this relation item", match: :first

    fill_in "Comment", with: @relation_item.comment
    fill_in "Country", with: @relation_item.country_id
    fill_in "Entity", with: @relation_item.entity_id
    fill_in "Entity type", with: @relation_item.entity_type
    fill_in "Value", with: @relation_item.value
    fill_in "Year", with: @relation_item.year
    click_on "Update Relation item"

    assert_text "Relation item was successfully updated"
    click_on "Back"
  end

  test "should destroy Relation item" do
    visit relation_item_url(@relation_item)
    click_on "Destroy this relation item", match: :first

    assert_text "Relation item was successfully destroyed"
  end
end
