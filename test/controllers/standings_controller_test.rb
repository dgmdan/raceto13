require 'test_helper'

class StandingsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "don't allow unauthenticated visitors" do
    get :index
    assert_redirected_to new_user_session_path
  end

  test "gets index" do
    sign_in users(:user)
    get :index
    assert_response :success
    assert_not_nil assigns(:entries)
    assert_not_nil assigns(:run_counts)
  end

end
