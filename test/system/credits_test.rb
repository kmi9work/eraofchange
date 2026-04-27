require "application_system_test_case"

class CreditsTest < ApplicationSystemTestCase
  setup do
    @credit = credits(:one)
  end

  test "visiting the index" do
    visit credits_url
    assert_selector "h1", text: "Credits"
  end

  test "should create credit" do
    visit credits_url
    click_on "New credit"

    fill_in "Deposit", with: @credit.deposit
    fill_in "Duration", with: @credit.duration
    fill_in "Procent", with: @credit.procent
    fill_in "Start year", with: @credit.start_year
    fill_in "Sum", with: @credit.sum
    click_on "Create Credit"

    assert_text "Credit was successfully created"
    click_on "Back"
  end

  test "should update Credit" do
    visit credit_url(@credit)
    click_on "Edit this credit", match: :first

    fill_in "Deposit", with: @credit.deposit
    fill_in "Duration", with: @credit.duration
    fill_in "Procent", with: @credit.procent
    fill_in "Start year", with: @credit.start_year
    fill_in "Sum", with: @credit.sum
    click_on "Update Credit"

    assert_text "Credit was successfully updated"
    click_on "Back"
  end

  test "should destroy Credit" do
    visit credit_url(@credit)
    click_on "Destroy this credit", match: :first

    assert_text "Credit was successfully destroyed"
  end
end
