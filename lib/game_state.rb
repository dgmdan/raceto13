# require 'byebug'

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
          check_for_hit(entry, query_date, score[:home_score], true)
        else
          check_for_hit(entry, query_date, score[:away_score], true)
        end
      end
    end
    puts "Loaded #{espn_scores.count} games"

    # With the new hits, see if any entries have won
    winners = []
    winner_sql = "SELECT entry_id FROM hits WHERE entry_id <> 0 GROUP BY entry_id HAVING COUNT(id) >= 14"
    winner_entry_ids = ActiveRecord::Base.connection.execute(winner_sql).collect{|x| x['entry_id']}
    if winner_entry_ids.size >= 1
      # We have a winner (or more than one)
      puts "Winner alert! Entry ids #{winner_entry_ids.join(',')}"
      winner_entry_ids.each do |entry_id|
        entry = Entry.find(entry_id)
        entry.won_at = Time.now
        entry.won_place = 1
        entry.save
        winners << entry
        UserMailer.win_email(entry,winner_entry_ids.count).deliver_now if entry.user.notification_types.where(name: 'conclude').any?
      end

      # Determine second place prize
      second_place_sql = "SELECT entry_id FROM hits WHERE entry_id <> 0 GROUP BY entry_id HAVING COUNT(id) = 13"
      second_place_entry_ids = ActiveRecord::Base.connection.execute(second_place_sql).collect{|x| x['entry_id']}
      second_place_entry_ids.each do |entry_id|
        entry = Entry.find(entry_id)
        entry.won_at = Time.now
        entry.won_place = 2
        entry.save
        winners << entry
        UserMailer.win_email(entry,second_place_entry_ids.count).deliver_now if entry.user.notification_types.where(name: 'conclude').any?
      end

      # Send an email to losers in the league telling them it's over
      Entry.active.losers.each do |entry|
        UserMailer.conclusion_email(entry, winners).deliver_now if entry.user.notification_types.where(name: 'conclude').any?
      end

    else
      puts "No winners for #{query_date}"
      # TODO: if it's the last day of the season, look for leagues with no winners, award win to whoever is closest
    end

    # Returns true if we found games
    espn_scores.any?
  end

  def self.reset_all_scores
    # TODO: futureproof this for more seasons
    start_date = Date.parse('2015-04-04')
    end_date = Date.yesterday
    (start_date..end_date).each do |current_date|
      self.reset_scores(current_date)
    end
  end

  def self.reset_scores(query_date)
    # Clear existing game data for this date
    Game.where(started_on: query_date).destroy_all

    # Loop through each MLB game on this date
    espn_scores = ESPN.get_mlb_scores(query_date)
    espn_scores.each do |score|
      home_team = Team.where(data_name: score[:home_team]).first
      away_team = Team.where(data_name: score[:away_team]).first

      # Keep log of games + scores
      Game.create(
          started_on: query_date,
          home_team: home_team,
          away_team: away_team,
          home_score: score[:home_score],
          away_score: score[:away_score]
      )

      # Create hits for those who earned one
      League.all.each do |league|
        next if league.complete?

        # Create hits
        entries = league.entries.where('team_id = ? OR team_id = ?', home_team, away_team)
        entries.each do |entry|
          if entry.team == home_team
            check_for_hit(entry, query_date, score[:home_score], false)
          else
            check_for_hit(entry, query_date, score[:away_score], false)
          end
        end

      end


    end
    puts "Loaded #{espn_scores.count} games"

    # Returns true if we found games
    espn_scores.any?
  end

  def self.create_hits(query_date)
    entries = Entry.active
    entries.each do |entry|
      home_match = Game.where(started_on: query_date, home_team_id: entry.team_id)
      away_match = Game.where(started_on: query_date, away_team_id: entry.team_id)

      home_match.each do |match|
        check_for_hit(entry, query_date, match.home_score, false)
      end

      away_match.each do |match|
        check_for_hit(entry, query_date, match.away_score, false)
      end
    end
  end

  def self.check_for_hit(entry, query_date, runs, enable_emails)
    return if runs > 13
    if Hit.where(entry: entry, runs: runs).empty?
      Rails.logger.debug "Creating hit for entry #{entry.id}, date #{query_date}, runs #{runs}"
      hit = Hit.create(entry: entry, hit_on: query_date, runs: runs)
      UserMailer.hit_email(hit).deliver_now if entry.user.notification_types.where(name: 'hit').any? && enable_emails
    end
  end

end