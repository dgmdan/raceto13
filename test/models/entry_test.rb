require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "don't allow >30 entries in a league" do
    6.times do |user_num|
      5.times do
        Entry.create(user: users(:"user#{user_num}") , league: leagues(:league1))
      end
    end
    assert_no_difference 'Entry.count' do
      Entry.create(user: users(:user0) , league: leagues(:league1))
    end
  end

  test "don't allow >5 entries from one user in one league" do
    5.times do
      Entry.create(user: users(:user0) , league: leagues(:league1))
    end
    assert_no_difference 'Entry.count' do
      Entry.create(user: users(:user0) , league: leagues(:league1))
    end
  end
end
