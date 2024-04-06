# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should not save a user without email' do
    user = users(:user1)
    user.email = nil
    assert_not user.save
  end

  test 'should not save a user without name' do
    user = users(:user1)
    user.name = nil
    assert_not user.save
  end

  test 'should not save a user without password' do
    user = users(:user1)
    user.encrypted_password = nil
    assert_raises ActiveRecord::StatementInvalid do
      user.save
    end
  end

  test 'should not be admin by default' do
    assert_equal users(:user1).admin, false
  end

  test 'admin column should power admin? method' do
    assert_equal users(:admin).admin?, true
    assert_equal users(:user1).admin?, false
  end

  test 'should have a gravatar url' do
    user = users(:user1)
    assert_match(%r{^http://www\.gravatar\.com/avatar/\w+$}, user.gravatar_url)
  end
end
