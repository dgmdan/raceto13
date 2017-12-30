require 'game_state'

class ScrapeScoresJob < ApplicationJob
  queue_as :default

  def perform(*args)
    last_game_date = Game.any? ? Game.maximum('started_on') : (Date.today-1)
    # There are days with no MLB games, so we need to keep advancing the date and trying again until we reach the current date
    last_game_date.upto(Date.today-1) { |current_date|
      GameState.scrape_games!(current_date)
    }
  end
end
