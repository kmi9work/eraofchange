require "test_helper"

class PlantLevelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plant_level = plant_levels(:one)
  end

  test "should get index" do
    get plant_levels_url
    assert_response :success
  end

  test "should get new" do
    get new_plant_level_url
    assert_response :success
  end

  test "should create plant_level" do
    assert_difference("PlantLevel.count") do
      post plant_levels_url, params: { plant_level: { charge: @plant_level.charge, deposit: @plant_level.deposit, formula: @plant_level.formula, level: @plant_level.level, max_product: @plant_level.max_product, price: @plant_level.price } }
    end

    assert_redirected_to plant_level_url(PlantLevel.last)
  end

  test "should show plant_level" do
    get plant_level_url(@plant_level)
    assert_response :success
  end

  test "should get edit" do
    get edit_plant_level_url(@plant_level)
    assert_response :success
  end

  test "should update plant_level" do
    patch plant_level_url(@plant_level), params: { plant_level: { charge: @plant_level.charge, deposit: @plant_level.deposit, formula: @plant_level.formula, level: @plant_level.level, max_product: @plant_level.max_product, price: @plant_level.price } }
    assert_redirected_to plant_level_url(@plant_level)
  end

  test "should destroy plant_level" do
    assert_difference("PlantLevel.count", -1) do
      delete plant_level_url(@plant_level)
    end

    assert_redirected_to plant_levels_url
  end
end
