require "application_system_test_case"

class InfluenceItemsTest < ApplicationSystemTestCase
  setup do
    @influence_item = influence_items(:one)
  end

  test "visiting the index" do
    visit influence_items_url
    assert_selector "h1", text: "Influence items"
  end

  test "should create influence item" do
    visit influence_items_url
    click_on "New influence item"

    fill_in "Comment", with: @influence_item.comment
    fill_in "Entity", with: @influence_item.entity_id
    fill_in "Entity type", with: @influence_item.entity_type
    fill_in "Player", with: @influence_item.player_id
    fill_in "Value", with: @influence_item.value
    fill_in "Year", with: @influence_item.year
    click_on "Create Influence item"

    assert_text "Influence item was successfully created"
    click_on "Back"
  end

  test "should update Influence item" do
    visit influence_item_url(@influence_item)
    click_on "Edit this influence item", match: :first

    fill_in "Comment", with: @influence_item.comment
    fill_in "Entity", with: @influence_item.entity_id
    fill_in "Entity type", with: @influence_item.entity_type
    fill_in "Player", with: @influence_item.player_id
    fill_in "Value", with: @influence_item.value
    fill_in "Year", with: @influence_item.year
    click_on "Update Influence item"

    assert_text "Influence item was successfully updated"
    click_on "Back"
  end

  test "should destroy Influence item" do
    visit influence_item_url(@influence_item)
    click_on "Destroy this influence item", match: :first

    assert_text "Influence item was successfully destroyed"
  end
end
