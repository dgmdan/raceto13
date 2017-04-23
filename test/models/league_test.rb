require 'test_helper'

class LeagueTest < ActiveSupport::TestCase
  setup do
    @league = leagues(:league1)
  end

  test "requires a name" do
    assert_no_difference 'League.count' do
      league = League.new
      league.starts_at = Date.today
      league.save
    end
  end

  test "requires a starts at" do
    assert_no_difference 'League.count' do
      league = League.new
      league.name = 'A League of My Own'
      league.save
    end
  end
  test "gets available teams" do
    available_teams = @league.available_teams
    assert_instance_of Array, available_teams
    assert_equal Team.count, available_teams.count
  end

  test "detect when league isn't complete" do
    refute @league.complete?
  end

  test "detect when league is complete" do
    Entry.create(user:users(:user0), league:leagues(:league1), won_at: Time.now, won_place: 1)
    Entry.create(user:users(:user0), league:leagues(:league1), won_at: Time.now, won_place: 2)
    assert @league.complete?
  end

  test "detect when league is full" do
    6.times do |user_num|
      5.times do
        Entry.create(user: users(:"user#{user_num}") , league: leagues(:league1))
      end
    end
    assert_includes League.full, @league
  end

  test "detect when league isn't full" do
    refute_includes League.full, @league
  end

end
