require 'byebug'

class GameState

  def self.get_espn_games(query_date)
    # Clear existing game data for this date
    Game.where(started_on: query_date).destroy_all

    # Loop through each MLB game on this date
    espn_scores = ESPN.get_mlb_scores(query_date)
    espn_scores.each do |score|
      home_team = Team.where(data_name: score[:home_team]).first
      away_team = Team.where(data_name: score[:away_team]).first

      # Keep log of games + scores even though we don't really need it
      Game.create(
          started_on: query_date,
          home_team: home_team,
          away_team: away_team,
          home_score: score[:home_score],
          away_score: score[:away_score]
      )

      # Create hits for those who earned one
      entries = Entry.where('team_id = ? OR team_id = ?', home_team, away_team)
      entries.each do |entry|
        if entry.team == home_team
          check_for_hit(entry, query_date, score[:home_score])
        else
          check_for_hit(entry, query_date, score[:away_score])
        end
      end
    end
    puts "Loaded #{espn_scores.count} games"

    # With the new hits, see if any entries have won
    winner_sql = "SELECT entry_id FROM hits WHERE entry_id <> 0 GROUP BY entry_id HAVING COUNT(id) >= 14"
    winner_entry_ids = ActiveRecord::Base.connection.execute(winner_sql).collect{|x| x['entry_id']}
    if winner_entry_ids.size > 1
      # Multiple winners
      puts "Multiple winners! entry ids #{winner_entry_ids.join(',')}"
      # TODO: send an email to admin for special handling
    elsif winner_entry_ids.size == 1
      # Single winner
      winning_entry = Entry.find(winner_entry_ids.first)
      puts "Winner is entry #{winning_entry.id}"
      winning_entry.won_at = Time.now
      winning_entry.save
      # TODO: send an email to user telling them that they won
      # TODO: send an email to everyone in the league telling them it's over
    else
      puts "No winners for #{query_date}"
      # TODO: if it's the last day of the season, look for leagues with no winners, award win to whoever is closest
    end

    # Returns true if we found games
    espn_scores.any?
  end

  def self.check_for_hit(entry, date, runs)
    return if runs > 13
    if Hit.where(entry: entry, runs: runs).empty?
      Rails.logger.debug "Creating hit for entry #{entry.id}, date #{date}, runs #{runs}"
      Hit.create(entry: entry, hit_on: date, runs: runs)
      # TODO: send user an email telling them they got a hit
    end
  end

end