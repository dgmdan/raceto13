require 'test_helper'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end

class GameStateTest < ActiveSupport::TestCase
  test "entire season game count equals known value" do
    VCR.use_cassette("mlb_scores_2014") do
      GameState.reset!

      # Get all scores for 2014 season
      start_date = Date.parse('2014-03-22')
      end_date = Date.parse('2014-09-28')
      (start_date..end_date).each do |date|
        GameState.scrape_games!(date)
      end

      assert_equal 2430, Game.count
    end
  end
end