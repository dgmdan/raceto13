class League < ActiveRecord::Base
  belongs_to :user
  has_many :league_users, dependent: :destroy
  has_many :users, through: :league_users
  has_many :entries, dependent: :destroy
  has_many :hits, through: :entries, dependent: :destroy

  validates :name, :starts_at, :ends_at, presence: true

  scope :full, -> { joins(:entries).where('entries.cancelled_at IS NULL').group('leagues.id').having('COUNT(entries.id) = 30') }

  def available_teams
    Team.all - entries.active.map(&:team)
  end

  def complete?
    entries.winners.any?
  end

  def get_and_record_winners!(query_date)
    winners = []

    # Only require 14-runs if it's before the end of season
    if self.ends_at.to_date <= query_date
      having_condition = ""
    else
      having_condition = "HAVING COUNT(DISTINCT hits.id) = 14"
    end

    # Look for win condition
    first_counts_sql = """
          SELECT COUNT(DISTINCT hits.id) hits,
            COUNT(DISTINCT games.id) game_count
          FROM entries
          JOIN hits ON hits.entry_id = entries.id
          JOIN teams ON teams.id = entries.team_id
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id) AND DATE(games.started_on) <= '#{query_date}'
          WHERE entries.league_id = #{id}
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          GROUP BY entries.id
          #{having_condition}
          ORDER BY hits DESC, game_count ASC
          LIMIT 1;
          """
    first_counts_results = ActiveRecord::Base.connection.execute(first_counts_sql)

    # Get all first-place winners
    if first_counts_results.count > 0
      first_winning_hits = first_counts_results.first['hits']
      first_winning_game_count = first_counts_results.first['game_count']
      first_winners_sql = """
      SELECT entries.id entry_id
          FROM entries
          JOIN hits ON hits.entry_id = entries.id
          JOIN teams ON teams.id = entries.team_id
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id) AND DATE(games.started_on) <= '#{query_date}'
          WHERE entries.league_id = #{id}
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          GROUP BY entries.id
          HAVING COUNT(DISTINCT hits.id) = #{first_winning_hits} AND COUNT(DISTINCT games.id) = #{first_winning_game_count};
      """
      first_winners = ActiveRecord::Base.connection.execute(first_winners_sql)
      first_entry_ids = first_winners.map { |x| x['entry_id'] }

      # Find second place winners
      second_counts_sql = """
      SELECT COUNT(DISTINCT hits.id) hits,
            COUNT(DISTINCT games.id) game_count
          FROM entries
          JOIN hits ON hits.entry_id = entries.id
          JOIN teams ON teams.id = entries.team_id
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id) AND DATE(games.started_on) <= '#{query_date}'
          WHERE entries.league_id = #{id}
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          AND entries.id NOT IN (#{first_entry_ids.join(',')})
          GROUP BY entries.id
          ORDER BY hits DESC, game_count ASC
          LIMIT 1;
      """
      second_counts_results = ActiveRecord::Base.connection.execute(second_counts_sql)
      second_winning_hits = second_counts_results.first['hits']
      second_winning_game_count = second_counts_results.first['game_count']
      second_winners_sql = """
      SELECT entries.id entry_id
          FROM entries
          JOIN hits ON hits.entry_id = entries.id
          JOIN teams ON teams.id = entries.team_id
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id) AND DATE(games.started_on) <= '#{query_date}'
          WHERE entries.league_id = #{id}
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          GROUP BY entries.id
          HAVING COUNT(DISTINCT hits.id) = #{second_winning_hits} AND COUNT(DISTINCT games.id) = #{second_winning_game_count};
      """
      second_winners = ActiveRecord::Base.connection.execute(second_winners_sql)

      # Mark winners
      first_winners.each { |result|
        entry = Entry.find(result['entry_id'])
        entry.won_at = Time.now
        entry.won_place = 1
        entry.game_count = first_winning_game_count
        entry.save
        winners << entry
      }
      second_winners.each { |result|
        entry = Entry.find(result['entry_id'])
        entry.won_at = Time.now
        entry.won_place = 2
        entry.game_count = second_winning_game_count
        entry.save
        winners << entry
      }

      # Set games played on losing entries
      self.losers.each { |entry|
        entry.game_count = entry.team.games.where('DATE(started_on) <= ?', query_date).count
        entry.save
      }
    end
    return winners
  end

  def losers
    entries.where(won_at: nil)
  end

  def winners(place)
    entries.where(won_place: place)
  end

end
