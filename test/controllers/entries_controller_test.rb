require 'test_helper'

class EntriesControllerTest < ActionController::TestCase

  test "should get index" do
    sign_in users(:user)
    get :index
    assert_response :success
    assert_not_nil assigns(:entries)
    assert_not_nil assigns(:registerable)
  end

  test "should allow buying an entry" do

  end

  test "should prevent buying an entry when league is full" do

  end

  test "should prevent buying an entry when user already has max entries" do

  end

  test "should allow an unpaid entry to be marked paid" do

  end
end
