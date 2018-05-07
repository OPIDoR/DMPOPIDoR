require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  setup do
    @static_page = static_pages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:static_pages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create static_page" do
    assert_difference('StaticPage.count') do
      post :create, static_page: { name: @static_page.name, url: @static_page.url }
    end

    assert_redirected_to static_page_path(assigns(:static_page))
  end

  test "should show static_page" do
    get :show, id: @static_page
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @static_page
    assert_response :success
  end

  test "should update static_page" do
    patch :update, id: @static_page, static_page: { name: @static_page.name, url: @static_page.url }
    assert_redirected_to static_page_path(assigns(:static_page))
  end

  test "should destroy static_page" do
    assert_difference('StaticPage.count', -1) do
      delete :destroy, id: @static_page
    end

    assert_redirected_to static_pages_path
  end
end
