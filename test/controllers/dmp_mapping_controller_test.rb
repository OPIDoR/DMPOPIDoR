require "test_helper"

class DmpMappingControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get dmp_mapping_show_url
    assert_response :success
  end

  test "should get create" do
    get dmp_mapping_create_url
    assert_response :success
  end

  test "should get edit" do
    get dmp_mapping_edit_url
    assert_response :success
  end

  test "should get update" do
    get dmp_mapping_update_url
    assert_response :success
  end

  test "should get delete" do
    get dmp_mapping_delete_url
    assert_response :success
  end
end
