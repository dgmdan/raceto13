require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "get teams in game" do
    game = games(:one)
    assert_instance_of Array, game.teams
    assert_equal game.teams.size, 2
  end
end
