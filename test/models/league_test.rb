require 'test_helper'

class LeagueTest < ActiveSupport::TestCase
  setup do
    @league = leagues(:one)
  end

  test "gets available teams" do
    available_teams = @league.available_teams
    assert_instance_of Array, available_teams
    assert_equal Team.count, available_teams.count
  end

  test "detect when league is registerable" do
    assert @league.registerable?
  end

  test "detect when league isn't registerable" do
    Entry.create(user:users(:user0), league:leagues(:one), team:teams(:one))
    refute @league.registerable?
  end

  test "detect when league isn't complete" do
    refute @league.complete?
  end

  test "detect when league is complete" do
    Entry.create(user:users(:user0), league:leagues(:one), team:teams(:one), won_at: Time.now)
    assert @league.complete?
  end

  test "detect when league is full" do
    6.times do |user_num|
      5.times do
        Entry.create(user: users(:"user#{user_num}") , league: leagues(:one))
      end
    end
    assert @league.full?
  end

  test "detect when league isn't full" do
    refute @league.full?
  end


end
