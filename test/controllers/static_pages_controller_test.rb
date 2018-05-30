require 'test_helper'

module SuperAdmin
  class StaticPagesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      sign_in User.first
      @static_page = StaticPage.find_by(name: 'Help')
      @static_page_attributes = {
        name: 'sp1',
        url: 'sp2'
      }
    end

    test 'should get index' do
      get :index
      assert_response :success
      assert_not_nil assigns(:static_pages)
    end

    test 'should get new' do
      get :new
      assert_response :success
    end

    test 'should create static_page' do
      assert_difference('StaticPage.count') do
        post :create, static_page: @static_page_attributes
      end

      assert_redirected_to super_admin_static_pages_path
      assert_not_nil assigns(:static_page)
    end

    test 'should get edit' do
      get :edit, id: @static_page
      assert_response :success
      assert_not_nil assigns(:static_page)
    end

    test 'should update static_page' do
      patch :update, id: @static_page, static_page: @static_page_attributes
      assert_redirected_to super_admin_static_pages_path
      assert_not_nil assigns(:static_page)
    end

    test 'should destroy static_page' do
      assert_difference('StaticPage.count', -1) do
        delete :destroy, id: @static_page
      end

      assert_redirected_to super_admin_static_pages_path
    end
  end
end
