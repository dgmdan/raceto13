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

    # Find each entry's number of hits and games
    winner_sql = """
          SELECT entries.id entry_id,
            COUNT(DISTINCT hits.id) hits,
            COUNT(DISTINCT games.id) game_count
          FROM entries
          JOIN hits ON hits.entry_id = entries.id
          JOIN teams ON teams.id = entries.team_id
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id)
          WHERE entries.league_id = #{id}
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          GROUP BY entries.id
          HAVING COUNT(DISTINCT hits.id) = 14
          ORDER BY hits DESC, game_count ASC
          LIMIT 2;
          """
    winner_results = ActiveRecord::Base.connection.execute(winner_sql)

    if winner_results.count == 1
      # Find a second place winner if necessary
      second_sql = """
      SELECT entries.id entry_id,
            COUNT(DISTINCT hits.id) hits,
            COUNT(DISTINCT games.id) game_count
          FROM entries
          JOIN hits ON hits.entry_id = entries.id
          JOIN teams ON teams.id = entries.team_id
          JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id)
          WHERE entries.league_id = #{id}
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          AND entries.id <> #{winner_results.first['entry_id']}
          GROUP BY entries.id
          ORDER BY hits DESC, game_count ASC
          LIMIT 1;
      """
      second_winner_results = ActiveRecord::Base.connection.execute(second_sql)
    end

    # If we have winners, mark them and return
    if winner_results.count > 0
      winner_results.each_with_index { |result, index|
        entry = Entry.find(result['entry_id'])
        entry.won_at = Time.now
        entry.won_place = index + 1
        entry.save
        winners << entry
      }
      if second_winner_results
        entry = Entry.find(second_winner_results.first['entry_id'])
        entry.won_at = Time.now
        entry.won_place = 2
        entry.save
        winners << entry
      end
      byebug
      return winners
    end

    # Check for end of season condition
    if ends_at <= query_date
      puts "End of season detected"
      end_season_sql = """
      SELECT entries.id entry_id,
          COUNT(DISTINCT games.id) game_count,
          COUNT(DISTINCT hits.id) hits
        FROM entries
        JOIN hits ON hits.entry_id = entries.id
        JOIN teams ON teams.id = entries.team_id
        JOIN games ON (games.home_team_id = teams.id OR games.away_team_id = teams.id)
        WHERE entries.league_id = #{id}
        AND entries.cancelled_at IS NULL
        AND entries.won_at IS NULL
        GROUP BY entries.id
        ORDER BY hits DESC, game_count ASC
        LIMIT 2;
      """
      end_season_results = ActiveRecord::Base.connection.execute(end_season_sql)
      end_season_results.each_with_index { |result, index|
        entry = Entry.find(result['entry_id'])
        entry.won_at = Time.now
        entry.won_place = index + 1
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
