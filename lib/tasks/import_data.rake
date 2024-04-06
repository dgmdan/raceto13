# frozen_string_literal: true

require 'game_state'

namespace :import_data do
  desc 'Import all MLB teams from ESPN'
  task teams: :environment do
    espn_teams = ESPN.get_teams_in('mlb')
    espn_teams.each_value do |teams|
      teams.each do |team|
        Team.create(name: team[:name], data_name: team[:data_name])
      end
    end
  end

  desc 'Import MLB games for the next day based on current data'
  task advance: [:environment] do |_t|
    ScrapeScoresJob.perform_later
  end

  desc 'Import MLB scores for a given date'
  task :get_games, [:query_date] => [:environment] do |_t, args|
    GameState.scrape_games!(args.query_date)
  end

  desc 'Import MLB scores for a past league (for running simulation)'
  task :get_league_games, [:league_id] => [:environment] do |_t, args|
    league = League.find_by(id: args.league_id)
    current_date = league.starts_at.to_date
    loop do
      current_date += 1
      GameState.scrape_games!(current_date)
      break if league.ends_at.to_date == current_date
    end
  end
end
