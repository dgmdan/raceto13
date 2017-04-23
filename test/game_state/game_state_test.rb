require 'byebug'
require 'rake'
require 'test_helper'

class GameStateTest < ActiveSupport::TestCase
  test "entire season game count equals known value" do
    GameState.reset!

    # Get all scores for 2014 season
    start_date = Date.parse('2014-03-30')
    end_date = Date.parse('2014-09-28') + 1
    (start_date..end_date).each do |date|
      GameState.scrape_games!(date)
    end

    assert_equal 2428, Game.count
  end

  test "winner is chosen at the end of regular season" do
    GameState.reset!

    league = leagues(:league2)
    (league.starts_at.to_date..league.ends_at.to_date+1).each do |date|
      GameState.scrape_games!(date)
    end

    first_winners = league.winners(1)
    second_winners = league.winners(2)
    byebug

    assert_equal 2, first_winners.count
    assert_equal 1, second_winners.count
    assert league.complete?
  end
end