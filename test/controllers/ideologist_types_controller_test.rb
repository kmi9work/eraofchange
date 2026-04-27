require "test_helper"

class IdeologistTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ideologist_type = ideologist_types(:one)
  end

  test "should get index" do
    get ideologist_types_url
    assert_response :success
  end

  test "should get new" do
    get new_ideologist_type_url
    assert_response :success
  end

  test "should create ideologist_type" do
    assert_difference("IdeologistType.count") do
      post ideologist_types_url, params: { ideologist_type: { name: @ideologist_type.name } }
    end

    assert_redirected_to ideologist_type_url(IdeologistType.last)
  end

  test "should show ideologist_type" do
    get ideologist_type_url(@ideologist_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_ideologist_type_url(@ideologist_type)
    assert_response :success
  end

  test "should update ideologist_type" do
    patch ideologist_type_url(@ideologist_type), params: { ideologist_type: { name: @ideologist_type.name } }
    assert_redirected_to ideologist_type_url(@ideologist_type)
  end

  test "should destroy ideologist_type" do
    assert_difference("IdeologistType.count", -1) do
      delete ideologist_type_url(@ideologist_type)
    end

    assert_redirected_to ideologist_types_url
  end
end
