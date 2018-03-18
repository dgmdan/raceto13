require 'rake'
require 'test_helper'

class GameStateTest < ActiveSupport::TestCase
  test "entire season game count equals known value" do
    # Get all scores for 2014 season
    start_date = Date.parse('2014-03-30')
    end_date = Date.parse('2014-09-28')
    (start_date..end_date).each do |date|
      GameState.scrape_games!(date)
    end

    assert_equal 2428, Game.count
  end

  test "winner is chosen at the end of regular season" do
    league = leagues(:league1)
    (league.starts_at.to_date..league.ends_at.to_date).each do |date|
      break if league.complete?
      GameState.scrape_games!(date)
    end

    first_winners = league.winners(1)
    second_winners = league.winners(2)

    assert first_winners.any?
    assert second_winners.any?
    assert league.complete?
  end

  test "winner is chosen when meet win conditions" do
    league = leagues(:league1)
    (league.starts_at.to_date..league.ends_at.to_date).each do |date|
      break if league.complete?
      GameState.scrape_games!(date)
    end

    first_winners = league.winners(1)
    second_winners = league.winners(2)

    assert first_winners.any?
    assert second_winners.any?
    assert league.complete?
  end
end