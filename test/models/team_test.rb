require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  test "should require name" do
    team = teams(:team)
    team.name = nil
    assert_not team.save
  end

  test "should require data name" do
    team = teams(:team)
    team.data_name = nil
    assert_not team.save
  end

  test "games method should return array of games" do
    games = teams(:team).games
    #TODO: figure out what assertions to do here
  end
end
