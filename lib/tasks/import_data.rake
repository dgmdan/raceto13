# require 'byebug'
require 'game_state'

namespace :import_data do

  desc 'Import all MLB teams from ESPN'
  task teams: :environment do
    espn_teams = ESPN.get_teams_in('mlb')
    espn_teams.each do |division, teams|
      teams.each do |team|
        Team.create(name: team[:name], data_name: team[:data_name])
      end
    end
  end

  desc 'Import MLB games for the next day based on current data'
  task :advance => [:environment] do |t|
    last_game_date = Game.maximum('started_on')
    # There are days with no MLB games, so we need to keep advancing the date and trying again until we reach the current date
    loop do
      last_game_date += 1
      break if last_game_date == Date.today || League.first.complete?
      GameState.get_espn_games(last_game_date)
    end
  end

  desc 'Import MLB scores for a given date'
  task :get_games, [:query_date] => [:environment] do |t, args|
    GameState.get_espn_games(args.query_date)
  end

end
