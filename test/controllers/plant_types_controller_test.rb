require "test_helper"

class PlantTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plant_type = plant_types(:one)
  end

  test "should get index" do
    get plant_types_url
    assert_response :success
  end

  test "should get new" do
    get new_plant_type_url
    assert_response :success
  end

  test "should create plant_type" do
    assert_difference("PlantType.count") do
      post plant_types_url, params: { plant_type: {  } }
    end

    assert_redirected_to plant_type_url(PlantType.last)
  end

  test "should show plant_type" do
    get plant_type_url(@plant_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_plant_type_url(@plant_type)
    assert_response :success
  end

  test "should update plant_type" do
    patch plant_type_url(@plant_type), params: { plant_type: {  } }
    assert_redirected_to plant_type_url(@plant_type)
  end

  test "should destroy plant_type" do
    assert_difference("PlantType.count", -1) do
      delete plant_type_url(@plant_type)
    end

    assert_redirected_to plant_types_url
  end
end
