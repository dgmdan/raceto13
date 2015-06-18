require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  test "should require name" do
    team = teams(:one)
    team.name = nil
    assert_not team.save
  end

  test "should require data name" do
    team = teams(:one)
    team.data_name = nil
    assert_not team.save
  end

  test "games method should return activerecord association to games" do
    games = teams(:one).games
    assert_instance_of Game::ActiveRecord_Relation, games
    assert_equal games.count, 2
  end

end
