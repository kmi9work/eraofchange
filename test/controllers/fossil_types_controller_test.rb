require "test_helper"

class FossilTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fossil_type = fossil_types(:one)
  end

  test "should get index" do
    get fossil_types_url
    assert_response :success
  end

  test "should get new" do
    get new_fossil_type_url
    assert_response :success
  end

  test "should create fossil_type" do
    assert_difference("FossilType.count") do
      post fossil_types_url, params: { fossil_type: { name: @fossil_type.name } }
    end

    assert_redirected_to fossil_type_url(FossilType.last)
  end

  test "should show fossil_type" do
    get fossil_type_url(@fossil_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_fossil_type_url(@fossil_type)
    assert_response :success
  end

  test "should update fossil_type" do
    patch fossil_type_url(@fossil_type), params: { fossil_type: { name: @fossil_type.name } }
    assert_redirected_to fossil_type_url(@fossil_type)
  end

  test "should destroy fossil_type" do
    assert_difference("FossilType.count", -1) do
      delete fossil_type_url(@fossil_type)
    end

    assert_redirected_to fossil_types_url
  end
end
