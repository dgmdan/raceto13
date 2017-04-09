class League < ActiveRecord::Base
  belongs_to :user
  has_many :league_users
  has_many :users, through: :league_users
  has_many :entries
  has_many :hits, through: :entries

  validates :name, :starts_at, :ends_at, presence: true

  scope :started, -> { where('starts_at <= ?', Time.now)  }
  scope :full, -> { joins(:entries).where('entries.cancelled_at IS NULL').group('leagues.id').having('COUNT(entries.id) = ?', Team.count) }

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
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id)
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
      winning_hits = first_counts_results.first['hits']
      winning_game_count = first_counts_results.first['game_count']
      first_winners_sql = """
      SELECT entries.id entry_id
          FROM entries
          JOIN hits ON hits.entry_id = entries.id
          JOIN teams ON teams.id = entries.team_id
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id)
          WHERE entries.league_id = #{id}
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          GROUP BY entries.id
          HAVING COUNT(DISTINCT hits.id) = #{winning_hits} AND COUNT(DISTINCT games.id) = #{winning_game_count};
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
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id)
          WHERE entries.league_id = #{id}
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          AND entries.id NOT IN (#{first_entry_ids.join(',')})
          GROUP BY entries.id
          ORDER BY hits DESC, game_count ASC
          LIMIT 1;
      """
      second_counts_results = ActiveRecord::Base.connection.execute(second_counts_sql)
      winning_hits = second_counts_results.first['hits']
      winning_game_count = second_counts_results.first['game_count']
      second_winners_sql = """
      SELECT entries.id entry_id
          FROM entries
          JOIN hits ON hits.entry_id = entries.id
          JOIN teams ON teams.id = entries.team_id
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id)
          WHERE entries.league_id = #{id}
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          GROUP BY entries.id
          HAVING COUNT(DISTINCT hits.id) = #{winning_hits} AND COUNT(DISTINCT games.id) = #{winning_game_count};
      """
      second_winners = ActiveRecord::Base.connection.execute(second_winners_sql)

      # Mark winners
      first_winners.each { |result|
        entry = Entry.find(result['entry_id'])
        entry.won_at = Time.now
        entry.won_place = 1
        entry.save
        winners << entry
      }
      second_winners.each { |result|
        entry = Entry.find(result['entry_id'])
        entry.won_at = Time.now
        entry.won_place = 2
        entry.save
        winners << entry
      }
    end
    return winners
  end

  def losers
    entries.where(won_at: nil)
  end

end
