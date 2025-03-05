require "test_helper"

class IdeologistTechnologiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ideologist_technology = ideologist_technologies(:one)
  end

  test "should get index" do
    get ideologist_technologies_url
    assert_response :success
  end

  test "should get new" do
    get new_ideologist_technology_url
    assert_response :success
  end

  test "should create ideologist_technology" do
    assert_difference("IdeologistTechnology.count") do
      post ideologist_technologies_url, params: { ideologist_technology: { ideologist_type_id: @ideologist_technology.ideologist_type_id, params: @ideologist_technology.params, requirements: @ideologist_technology.requirements, name: @ideologist_technology.name } }
    end

    assert_redirected_to ideologist_technology_url(IdeologistTechnology.last)
  end

  test "should show ideologist_technology" do
    get ideologist_technology_url(@ideologist_technology)
    assert_response :success
  end

  test "should get edit" do
    get edit_ideologist_technology_url(@ideologist_technology)
    assert_response :success
  end

  test "should update ideologist_technology" do
    patch ideologist_technology_url(@ideologist_technology), params: { ideologist_technology: { ideologist_type_id: @ideologist_technology.ideologist_type_id, params: @ideologist_technology.params, requirements: @ideologist_technology.requirements, name: @ideologist_technology.name } }
    assert_redirected_to ideologist_technology_url(@ideologist_technology)
  end

  test "should destroy ideologist_technology" do
    assert_difference("IdeologistTechnology.count", -1) do
      delete ideologist_technology_url(@ideologist_technology)
    end

    assert_redirected_to ideologist_technologies_url
  end
end
