require "test_helper"

class RecourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recource = recources(:one)
  end

  test "should get index" do
    get recources_url
    assert_response :success
  end

  test "should get new" do
    get new_recource_url
    assert_response :success
  end

  test "should create recource" do
    assert_difference("Recource.count") do
      post recources_url, params: { recource: {  } }
    end

    assert_redirected_to recource_url(Recource.last)
  end

  test "should show recource" do
    get recource_url(@recource)
    assert_response :success
  end

  test "should get edit" do
    get edit_recource_url(@recource)
    assert_response :success
  end

  test "should update recource" do
    patch recource_url(@recource), params: { recource: {  } }
    assert_redirected_to recource_url(@recource)
  end

  test "should destroy recource" do
    assert_difference("Recource.count", -1) do
      delete recource_url(@recource)
    end

    assert_redirected_to recources_url
  end
end
