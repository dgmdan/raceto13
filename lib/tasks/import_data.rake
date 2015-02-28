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

  desc 'Import MLB scores for a certain day'
  task :scores, [:query_date] => :environment do |t, args|
    puts ESPN.get_mlb_scores(args.query_date)
  end

end
