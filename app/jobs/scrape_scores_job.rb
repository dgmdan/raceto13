# frozen_string_literal: true

require 'game_state'

class ScrapeScoresJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    last_game_date = Game.any? ? Game.maximum('started_on') : (Date.today - 1)
    # some days have zero MLB games, so we keep advancing the date until we reach the current date
    last_game_date.upto(Date.today - 1) do |current_date|
      GameState.scrape_games!(current_date)
    end
  end
end
