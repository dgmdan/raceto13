# frozen_string_literal: true

require 'test_helper'

class EntriesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @user = users(:user2)
    @league = leagues(:league1)
    @user.leagues << @league
    @user.save
  end

  test 'should list my entries' do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:entries)
    assert_not_nil assigns(:selected_league)
  end

  test 'should allow buying an entry' do
    sign_in @user
    assert_difference 'Entry.count', 2 do
      post :buy, params: { quantity: '2', league_id: @league.id }
    end
    assert_redirected_to league_entries_path(@league.id)
  end

  test 'should prevent buying an entry on errors' do
    sign_in @user
    post :buy, params: { quantity: 5, league_id: @league.id }
    assert_no_difference('Entry.count') do
      post :buy, params: { quantity: 1, league_id: @league.id }
    end
    assert_redirected_to league_entries_path(@league)
  end

  test 'should allow an unpaid entry to be marked paid' do
    sign_in users(:admin)
    post :pay, params: { id: Entry.first }
    assert_not_nil Entry.first.paid_at
  end

  test 'should not allow non-admin users to mark things as paid' do
    sign_in @user
    post :buy, params: { quantity: 1, league_id: @league.id }
    post :pay, params: { id: Entry.first }
    assert_nil Entry.first.paid_at
  end
end
