# frozen_string_literal: true

class GameState
  def self.scrape_games!(query_date)
    puts query_date

    # Re-use existing game data for this date
    games = Game.where(started_on: query_date)

    if games.count.zero?
      # No game data, need to scrape it
      games = []
      espn_scores = ESPN.get_mlb_scores(query_date)
      espn_scores.each do |score|
        home_team = Team.where(data_name: score[:home_team]).first
        away_team = Team.where(data_name: score[:away_team]).first

        next unless home_team && away_team

        # Keep log of games + scores
        game = Game.create(
          started_on: query_date,
          home_team:,
          away_team:,
          home_score: score[:home_score],
          away_score: score[:away_score]
        )
        games << game
      end
      puts "Loaded #{espn_scores.count} games"
    end

    games.each do |game|
      # Create hits for those who earned one
      League.all.each do |league|
        next if league.complete?

        entries = league.entries.where('team_id = ? OR team_id = ?', game.home_team.id, game.away_team.id)
        entries.each do |entry|
          if entry.team == game.home_team
            check_for_hit!(entry, game.id, query_date, game.home_score, true)
          else
            check_for_hit!(entry, game.id, query_date, game.away_score, true)
          end
        end
      end
    end

    # With the new hits, see if any entries have won
    League.all.each do |league|
      next if league.complete?

      winners = league.get_and_record_winners!(query_date)
      next unless winners.size.positive?

      puts 'Winner found!'

      # Send an email to winners
      winners.each do |entry|
        if entry.user.notification_types.where(name: 'conclude').any?
          UserMailer.win_email(entry,
                               winners.count).deliver_later
        end
      end

      # Send an email to losers
      league.losers.each do |entry|
        if entry.user.notification_types.where(name: 'conclude').any?
          UserMailer.conclusion_email(entry,
                                      winners).deliver_later
        end
      end
    end
  end

  def self.reset_all_scores!
    # TODO: futureproof this for more seasons
    start_date = Date.parse('2015-04-04')
    end_date = Date.yesterday
    (start_date..end_date).each do |current_date|
      reset_scores!(current_date)
    end
  end

  def self.reset!
    Hit.destroy_all
    Game.destroy_all
    Entry.all.each do |entry|
      entry.won_at = nil
      entry.won_place = nil
      entry.game_count = nil
      entry.save
    end
  end

  def self.create_hits!(query_date)
    entries = Entry.active
    entries.each do |entry|
      next if entry.league.complete?

      home_match = Game.where(started_on: query_date, home_team_id: entry.team_id)
      away_match = Game.where(started_on: query_date, away_team_id: entry.team_id)

      home_match.each do |match|
        check_for_hit!(entry, match.id, query_date, match.home_score, false)
      end

      away_match.each do |match|
        check_for_hit!(entry, match.id, query_date, match.away_score, false)
      end
    end
  end

  def self.check_for_hit!(entry, game_id, query_date, runs, enable_emails)
    return if runs > 13

    return unless Hit.where(entry:, runs:).empty?

    Rails.logger.debug "Creating hit for entry #{entry.id}, date #{query_date}, runs #{runs}"
    hit = Hit.create(entry:, hit_on: query_date, runs:, game_id:)
    UserMailer.hit_email(hit).deliver_later if entry.user.notification_types.where(name: 'hit').any? && enable_emails
  end
end
