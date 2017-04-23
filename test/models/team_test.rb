require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  test "should require name" do
    team = Team.new
    team.data_name = 'blah'
    assert_not team.save
  end

  test "should require data name" do
    team = Team.new
    team.name = 'blah'
    assert_not team.save
  end

  test "games method should return activerecord association to games" do
    team = Team.create(name: 'blah', data_name: 'blah')
    games = team.games
    assert_instance_of Game::ActiveRecord_Relation, games
    assert_equal 0, games.count
  end

end
