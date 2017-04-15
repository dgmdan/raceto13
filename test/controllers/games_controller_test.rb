require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should not allow non-users" do
    get :index
    assert_redirected_to new_user_session_path
  end

  test "should get index" do
    sign_in users(:admin)
    get :index
    assert_response :success
    assert_not_nil assigns(:games)
  end

  test "should get mass entry form" do
    #TODO: implement this test
  end

  test "should mass create games" do
    #TODO: implement this test
  end
end
