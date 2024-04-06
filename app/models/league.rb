# frozen_string_literal: true

class League < ApplicationRecord
  belongs_to :user
  has_many :league_users, dependent: :destroy
  has_many :users, through: :league_users
  has_many :entries, dependent: :destroy
  has_many :hits, through: :entries, dependent: :destroy

  validates :name, :starts_at, :ends_at, presence: true

  before_create :set_invite_uuid

  scope :full, lambda {
                 joins(:entries).where('entries.cancelled_at IS NULL').group('leagues.id').having('COUNT(entries.id) = 30')
               }

  def available_teams
    Team.all - entries.active.map(&:team)
  end

  def complete?
    entries.winners.any?
  end

  def get_and_record_winners!(query_date)
    winners = []

    # Only require 14-runs if it's before the end of season
    having_condition = if ends_at.to_date <= query_date
                         ''
                       else
                         'HAVING COUNT(DISTINCT hits.id) = 14'
                       end

    # Look for win condition
    first_counts_sql = ''"
          SELECT COUNT(DISTINCT hits.id) hits,
            COUNT(DISTINCT games.id) game_count
          FROM entries
          JOIN hits ON hits.entry_id = entries.id
          JOIN teams ON teams.id = entries.team_id
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id) AND DATE(games.started_on) <= '#{ActiveRecord::Base.sanitize_sql query_date}'
          WHERE entries.league_id = #{id}
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          GROUP BY entries.id
          #{ActiveRecord::Base.sanitize_sql having_condition}
          ORDER BY hits DESC, game_count ASC
          LIMIT 1;
          "''
    first_counts_results = ApplicationRecord.connection.execute(first_counts_sql)
    return [] if first_counts_results.count.zero?

    # Get all first-place winners
    first_winning_hits = first_counts_results.first['hits']
    first_winning_game_count = first_counts_results.first['game_count']
    first_winners_sql = ''"
    SELECT entries.id AS entry_id, entries.game_count AS game_count
        FROM entries
        JOIN hits ON hits.entry_id = entries.id
        JOIN teams ON teams.id = entries.team_id
        JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id) AND DATE(games.started_on) <= '#{ActiveRecord::Base.sanitize_sql query_date}'
        WHERE entries.league_id = #{id}
        AND entries.cancelled_at IS NULL
        AND entries.won_at IS NULL
        GROUP BY entries.id
        HAVING COUNT(DISTINCT hits.id) = #{ActiveRecord::Base.sanitize_sql first_winning_hits} AND COUNT(DISTINCT games.id) = #{ActiveRecord::Base.sanitize_sql first_winning_game_count};
    "''
    first_winners = ApplicationRecord.connection.execute(first_winners_sql)
    first_entry_ids = first_winners.map { |x| x['entry_id'] }
    first_game_count = first_winners.first['game_count'] || first_winning_game_count

    # Find second place winners
    second_counts_sql = ''"
    SELECT COUNT(DISTINCT hits.id) hits,
          COUNT(DISTINCT games.id) game_count
        FROM entries
        JOIN hits ON hits.entry_id = entries.id
        JOIN teams ON teams.id = entries.team_id
        JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id) AND DATE(games.started_on) <= '#{ActiveRecord::Base.sanitize_sql query_date}'
        WHERE entries.league_id = #{ActiveRecord::Base.sanitize_sql id}
        AND entries.cancelled_at IS NULL
        AND entries.won_at IS NULL
        AND entries.id NOT IN (#{ActiveRecord::Base.sanitize_sql first_entry_ids.join(',')})
        GROUP BY entries.id
        ORDER BY hits DESC, game_count ASC
        LIMIT 1;
    "''
    second_counts_results = ApplicationRecord.connection.execute(second_counts_sql)
    second_winning_hits = second_counts_results.first['hits']
    second_winning_game_count = second_counts_results.first['game_count']
    second_winners_sql = ''"
    SELECT entries.id AS entry_id, entries.game_count AS game_count
        FROM entries
        JOIN hits ON hits.entry_id = entries.id
        JOIN teams ON teams.id = entries.team_id
        JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id) AND DATE(games.started_on) <= '#{ActiveRecord::Base.sanitize_sql query_date}'
        WHERE entries.league_id = #{ActiveRecord::Base.sanitize_sql id}
        AND entries.cancelled_at IS NULL
        AND entries.won_at IS NULL
        GROUP BY entries.id
        HAVING COUNT(DISTINCT hits.id) = #{ActiveRecord::Base.sanitize_sql second_winning_hits} AND COUNT(DISTINCT games.id) = #{ActiveRecord::Base.sanitize_sql second_winning_game_count};
    "''
    second_winners = ApplicationRecord.connection.execute(second_winners_sql)
    second_entry_ids = second_winners.map { |x| x['entry_id'] }
    second_game_count = second_winners.first['game_count'] || second_winning_game_count

    # Look for potential ties
    #   HOW MANY HITS BEHIND: (#{first_winning_hits} - COUNT(DISTINCT hits.id))
    #   HOW MANY GAMES BEHIND: (#{first_winning_game_count} - COUNT(DISTINCT games.id))
    #   GAMES BEHIND MUST BE >= HITS BEHIND
    first_tie_sql = ''"
      SELECT 1
          FROM entries
          JOIN hits ON hits.entry_id = entries.id
          JOIN teams ON teams.id = entries.team_id
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id) AND DATE(games.started_on) <= '#{ActiveRecord::Base.sanitize_sql query_date}'
          WHERE entries.league_id = #{ActiveRecord::Base.sanitize_sql id}
          AND entries.id NOT IN (#{ActiveRecord::Base.sanitize_sql first_entry_ids.join(',')})
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          GROUP BY entries.id
          HAVING (#{ActiveRecord::Base.sanitize_sql first_game_count} - COUNT(DISTINCT games.id)) >= (#{ActiveRecord::Base.sanitize_sql first_winning_hits} - COUNT(DISTINCT hits.id))
      UNION
        SELECT 1
        FROM entries
        JOIN hits ON hits.entry_id = entries.id
        JOIN teams ON teams.id = entries.team_id
        JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id) AND DATE(games.started_on) <= '#{ActiveRecord::Base.sanitize_sql query_date}'
        WHERE entries.league_id = #{id}
        AND entries.id NOT IN (#{ActiveRecord::Base.sanitize_sql second_entry_ids.join(',')})
        AND entries.cancelled_at IS NULL
        AND entries.won_at IS NULL
        GROUP BY entries.id
        HAVING (#{ActiveRecord::Base.sanitize_sql second_game_count} - COUNT(DISTINCT games.id)) >= (#{ActiveRecord::Base.sanitize_sql second_winning_hits} - COUNT(DISTINCT hits.id));
    "''
    first_tie_results = ApplicationRecord.connection.execute(first_tie_sql)
    if first_tie_results.any?
      # Set the game_count for pending winner entries, indicating that other entries cannot exceed this number of games played.
      Entry.where(id: first_entry_ids, game_count: nil).update_all(game_count: first_winning_game_count)
      Entry.where(id: second_entry_ids, game_count: nil).update_all(game_count: second_winning_game_count)
      return []
    end

    # Mark winners
    first_winners.each do |result|
      entry = Entry.find(result['entry_id'])
      entry.won_at = Time.now
      entry.won_place = 1
      entry.save
      winners << entry
    end
    second_winners.each do |result|
      entry = Entry.find(result['entry_id'])
      entry.won_at = Time.now
      entry.won_place = 2
      entry.save
      winners << entry
    end

    # Set games played on losing entries
    losers.each do |entry|
      entry.game_count = entry.team.games.where('DATE(started_on) <= ?', query_date).count
      entry.save
    end

    winners
  end

  def losers
    entries.where(won_at: nil)
  end

  def winners(place)
    entries.where(won_place: place)
  end

  private

  def set_invite_uuid
    self.invite_uuid = SecureRandom.uuid
  end
end
