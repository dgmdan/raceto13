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
    # puts ESPN.get_mlb_scores(args.query_date)
    # :game_date=>"2015-03-15", :home_team=>"chw", :away_team=>"laa", :home_score=>5, :away_score=>3, :league=>"mlb"}

    # Clear existing game data for this date
    Game.where(started_on: args.query_date).destroy_all

    # Loop through each MLB game on this date
    espn_scores = ESPN.get_mlb_scores(args.query_date)
    espn_scores.each do |score|
      # HERE: these are not getting set correctly
      home_team = Team.where(data_name: score['home_team']).first
      away_team = Team.where(data_name: score['away_team']).first

      # Keep log of games + scores even though we don't really need it
      Game.create(
          started_on: args.query_date,
          home_team: home_team,
          away_team: away_team,
          home_score: score['home_score'],
          away_score: score['away_score']
      )

      # Create hits for those who earned one
      entries = Entry.where('team_id IN (?,?)', home_team.id, away_team.id)
      entries.each do |entry|
        if entry.team == home_team
          check_for_hit(entry.team, args.query_date, score['home_score'])
        else
          check_for_hit(entry.team, args.query_date, score['away_score'])
        end
      end
    end

    # With the new hits, see if any entries have won
    winners = Hit.select('entry_id').group('entry_id').having('COUNT(id) = 14')
    winners.each do |winner|
      winning_entry = Entry.find(winner.entry_id)

      other_winners = winners.where("league_id = ? AND user_id <> ?", winning_entry.league_id, winning_entry.user_id)
      if other_winners.any?
        # Multiple winners
        logger.debug "Multiple winners for league #{winner.league_id}"
        # TODO: send an email to admin for special handling
      else
        # Single winner
        logger.debug "Winner for league #{winner.league_id} is entry #{winning_entry.id}"
        winning_entry.won_at = Time.now
        winning_entry.save
        # TODO: send an email to user telling them that they won
        # TODO: send an email to everyone in the league telling them it's over
      end

    end

    # TODO: if it's the last day of the season, look for leagues with no winners, award win to whoever is closest
  end

  def check_for_hit(entry, date, runs)
    return if runs > 13
    unless Hit.where(entry: entry, hit_on: date, runs: runs).any?
      logger.debug "Creating hit for entry #{entry.id}, date #{date}, runs #{runs}"
      Hit.create(entry: entry, hit_on: date, runs: runs)
      # TODO: send user an email telling them they got a hit
    end
  end

end
