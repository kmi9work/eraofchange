require "test_helper"

class PlantCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plant_category = plant_categories(:one)
  end

  test "should get index" do
    get plant_categories_url
    assert_response :success
  end

  test "should get new" do
    get new_plant_category_url
    assert_response :success
  end

  test "should create plant_category" do
    assert_difference("PlantCategory.count") do
      post plant_categories_url, params: { plant_category: {  } }
    end

    assert_redirected_to plant_category_url(PlantCategory.last)
  end

  test "should show plant_category" do
    get plant_category_url(@plant_category)
    assert_response :success
  end

  test "should get edit" do
    get edit_plant_category_url(@plant_category)
    assert_response :success
  end

  test "should update plant_category" do
    patch plant_category_url(@plant_category), params: { plant_category: {  } }
    assert_redirected_to plant_category_url(@plant_category)
  end

  test "should destroy plant_category" do
    assert_difference("PlantCategory.count", -1) do
      delete plant_category_url(@plant_category)
    end

    assert_redirected_to plant_categories_url
  end
end
