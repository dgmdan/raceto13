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
      end_date = Date.parse('2014-09-28')
      (start_date..end_date).each do |date|
        GameState.scrape_games!(date)
      end

      # 162 games * 30 teams / 2 teams per game + 2 fixture games = 2432 games
      assert_equal 2432, Game.count
    end
  end
end