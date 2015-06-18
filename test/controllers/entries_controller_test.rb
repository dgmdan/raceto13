require 'test_helper'

class EntriesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should list my entries" do
    sign_in users(:user)
    get :index
    assert_response :success
    assert_not_nil assigns(:entries)
    assert_not_nil assigns(:registerable)
  end

  test "should allow buying an entry" do
    sign_in users(:user)
    assert_difference('Entry.count') do
      post :buy, quantity: 1
    end
    assert_redirected_to entries_path
  end

  test "should prevent buying an entry on errors" do
    sign_in users(:user)

    # Simulate maxing out a user's entries in a league
    while Entry.count < 5
      post :buy, quantity: 1
    end

    assert_no_difference('Entry.count') do
      post :buy, quantity: 1
    end
    assert_redirected_to entries_path
  end

  test "should allow an unpaid entry to be marked paid" do
    sign_in users(:admin)
    post :buy, quantity: 1
    post :pay, id: Entry.first
    assert_not_nil Entry.first.paid_at
  end

  test "should not allow non-admin users to mark things as paid" do
    sign_in users(:user)
    post :buy, quantity: 1
    post :pay, id: Entry.first
    assert_nil Entry.first.paid_at
  end
end
