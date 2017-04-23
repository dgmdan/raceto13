require 'byebug'
require 'rake'
require 'test_helper'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
  config.allow_http_connections_when_no_cassette = true
end

class GameStateTest < ActiveSupport::TestCase
  test "entire season game count equals known value" do
    Rake::Task['import_data:teams'].invoke
    VCR.use_cassette("mlb_scores_2014") do
      GameState.reset!

      # Get all scores for 2014 season
      start_date = Date.parse('2014-03-30')
      end_date = Date.parse('2014-09-28') + 1
      (start_date..end_date).each do |date|
        GameState.scrape_games!(date)
      end

      assert_equal 2428, Game.count
    end
  end

  test "winner is chosen at the end of regular season" do
    Runspool::Application.load_tasks
    Rake::Task['import_data:teams'].invoke
    GameState.reset!
    Rake::Task['game_state:assign_teams'].invoke
    VCR.use_cassette("mlb_scores_2014") do
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
end