class GameState

  def self.scrape_games!(query_date)
    # Clear existing game data for this date
    Game.where(started_on: query_date).destroy_all

    # Loop through each MLB game on this date
    espn_scores = ESPN.get_mlb_scores(query_date)
    espn_scores.each do |score|
      home_team = Team.where(data_name: score[:home_team]).first
      away_team = Team.where(data_name: score[:away_team]).first

      next unless home_team and away_team

      # Keep log of games + scores even though we don't really need it
      Game.create(
          started_on: query_date,
          home_team: home_team,
          away_team: away_team,
          home_score: score[:home_score],
          away_score: score[:away_score]
      )

      # Create hits for those who earned one
      League.started.each do |league|
        next if league.complete?
        entries = league.entries.where('team_id = ? OR team_id = ?', home_team, away_team)
        entries.each do |entry|
          if entry.team == home_team
            check_for_hit!(entry, query_date, score[:home_score], true)
          else
            check_for_hit!(entry, query_date, score[:away_score], true)
          end
        end
      end
    end
    puts "Loaded #{espn_scores.count} games on #{query_date}"

    # With the new hits, see if any entries have won
    League.started.each do |league|
      next if league.complete?
      winners = league.get_and_record_winners!
      if winners.size > 0
        puts 'Winner found!'

        # Send an email to winners
        winners.each do |entry|
          UserMailer.win_email(entry, winners.count).deliver_now if entry.user.notification_types.where(name: 'conclude').any?
        end

        # Send an email to losers
        league.losers.each do |entry|
          UserMailer.conclusion_email(entry, winners).deliver_now if entry.user.notification_types.where(name: 'conclude').any?
        end
      end
    end

    # Returns true if we found games
    espn_scores.any?
  end

  def self.reset_all_scores!
    # TODO: futureproof this for more seasons
    start_date = Date.parse('2015-04-04')
    end_date = Date.yesterday
    (start_date..end_date).each do |current_date|
      self.reset_scores!(current_date)
    end
  end

  def self.reset!
    Game.destroy_all
    Hit.destroy_all
    Entry.all.each do |entry|
      entry.won_at = nil
      entry.won_place = nil
      entry.game_count = nil
      entry.save
    end
  end

  def self.rebuild_hits!(query_date)
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
            check_for_hit!(entry, query_date, score[:home_score], false)
          else
            check_for_hit!(entry, query_date, score[:away_score], false)
          end
        end

      end


    end
    puts "Loaded #{espn_scores.count} games"

    # Returns true if we found games
    espn_scores.any?
  end

  def self.create_hits!(query_date)
    entries = Entry.active
    entries.each do |entry|
      next if entry.league.complete?
      home_match = Game.where(started_on: query_date, home_team_id: entry.team_id)
      away_match = Game.where(started_on: query_date, away_team_id: entry.team_id)

      home_match.each do |match|
        check_for_hit!(entry, query_date, match.home_score, false)
      end

      away_match.each do |match|
        check_for_hit!(entry, query_date, match.away_score, false)
      end
    end
  end

  def self.check_for_hit!(entry, query_date, runs, enable_emails)
    return if runs > 13
    if Hit.where(entry: entry, runs: runs).empty?
      Rails.logger.debug "Creating hit for entry #{entry.id}, date #{query_date}, runs #{runs}"
      hit = Hit.create(entry: entry, hit_on: query_date, runs: runs)
      UserMailer.hit_email(hit).deliver_now if entry.user.notification_types.where(name: 'hit').any? && enable_emails
    end
  end

end