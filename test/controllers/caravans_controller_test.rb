require "test_helper"

class CaravansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @caravan = caravans(:one)
  end

  test "should get index" do
    get caravans_url
    assert_response :success
  end

  test "should get new" do
    get new_caravan_url
    assert_response :success
  end

  test "should create caravan" do
    assert_difference("Caravan.count") do
      post caravans_url, params: { caravan: { body: @caravan.body, title: @caravan.title } }
    end

    assert_redirected_to caravan_url(Caravan.last)
  end

  test "should show caravan" do
    get caravan_url(@caravan)
    assert_response :success
  end

  test "should get edit" do
    get edit_caravan_url(@caravan)
    assert_response :success
  end

  test "should update caravan" do
    patch caravan_url(@caravan), params: { caravan: { body: @caravan.body, title: @caravan.title } }
    assert_redirected_to caravan_url(@caravan)
  end

  test "should destroy caravan" do
    assert_difference("Caravan.count", -1) do
      delete caravan_url(@caravan)
    end

    assert_redirected_to caravans_url
  end
end
