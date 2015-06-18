require 'test_helper'

class LeaguesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    # TODO: The concept of leagues hasn't been fully implemented yet. Need to refactor code that assumes only one league.
    @league = leagues(:one)
  end

  test "should not allow non-admin users" do
    sign_in users(:user)
    get :index
    assert_redirected_to new_user_session_path
  end

  test "should get index" do
    sign_in users(:admin)
    get :index
    assert_response :success
    assert_not_nil assigns(:leagues)
  end

  test "should get new" do
    sign_in users(:admin)
    get :new
    assert_response :success
  end

  test "should create league" do
    sign_in users(:admin)
    assert_difference('League.count') do
      post :create, league: { name: @league.name, user_id: @league.user_id }
    end

    assert_redirected_to league_path(assigns(:league))
  end

  test "should show league" do
    sign_in users(:admin)
    get :show, id: @league
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:admin)
    get :edit, id: @league
    assert_response :success
  end

  test "should update league" do
    sign_in users(:admin)
    patch :update, id: @league, league: { name: @league.name, user_id: @league.user_id }
    assert_redirected_to league_path(assigns(:league))
  end

  test "should destroy league" do
    sign_in users(:admin)
    assert_difference('League.count', -1) do
      delete :destroy, id: @league
    end
    assert_redirected_to leagues_path
  end

end
