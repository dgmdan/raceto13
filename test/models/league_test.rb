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

  test "detect when league is started" do
    assert_includes League.started, @league
  end

  test "detect when league isn't started" do
    Entry.create(user:users(:user0), league:leagues(:future), team:teams(:one))
    refute_includes League.started, leagues(:future)
  end

  test "detect when league isn't complete" do
    refute_includes League.complete, @league
  end

  test "detect when league is complete" do
    Entry.create(user:users(:user0), league:leagues(:one), team:teams(:one), won_at: Time.now)
    assert_includes League.complete, @league
  end

  test "detect when league is full" do
    6.times do |user_num|
      5.times do
        Entry.create(user: users(:"user#{user_num}") , league: leagues(:one))
      end
    end
    assert_includes League.full, @league
  end

  test "detect when league isn't full" do
    refute_includes League.full, @league
  end


end
