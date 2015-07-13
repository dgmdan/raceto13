class League < ActiveRecord::Base
  belongs_to :user
  has_many :league_users
  has_many :users, through: :league_users
  has_many :entries
  has_many :hits, through: :entries

  validates :name, :starts_at, presence: true

  scope :started, -> { where('starts_at <= ?', Time.now)  }
  scope :full, -> { joins(:entries).where('entries.cancelled_at IS NULL').group('leagues.id').having('COUNT(entries.id) = ?', Team.count) }

  def available_teams
    Team.all - entries.active.map(&:team)
  end

  def complete?
    entries.winners_in_place(1).any? && entries.winners_in_place(2).any?
  end

  def get_and_record_winners!
    winners = []

    # Find each entry's number of hits and games
    standings_sql = """
          SELECT entries.id entry_id,
            entries.possible_winner_game_count possible_winner_game_count,
            COUNT(DISTINCT hits.id) hits,
            COUNT(DISTINCT games.id) games
          FROM entries
          LEFT JOIN hits ON hits.entry_id = entries.id
          LEFT JOIN games ON games.home_team_id = entries.team_id OR games.away_team_id = entries.team_id
          WHERE entries.league_id = #{id}
          AND entries.cancelled_at IS NULL
          AND entries.won_at IS NULL
          GROUP BY entries.id"""
    standings = ActiveRecord::Base.connection.execute(standings_sql)

    # Check for 1st and 2nd place winners
    2.times do |place|
      if place == 0 && entries.winners_in_place(1).any? # We already have a 1st place winner
        next
      elsif place == 1 && entries.winners_in_place(1).empty? # Don't pick 2nd place winner if we can't decide on 1st
        return []
      end

      # Find possible winners
      possible_winners = standings.select { |entry| entry['hits'] == (14 - place) }

      # Handle if 2nd place has < 13 runs
      if possible_winners.empty? && place == 1
        place_buffer = 0
        loop do
          place_buffer += 1
          possible_winners = standings.select { |entry| entry['hits'] == (14 - place - place_buffer) }
          break if possible_winners.any?
        end
      end

      # See if anyone else could catch up to win/tie
      if possible_winners.any?
        game_counts = possible_winners.collect { |possible_winner| possible_winner['possible_winner_game_count'] ? possible_winner['possible_winner_game_count'] : possible_winner['games'] }
        entry_ids = possible_winners.collect{ |possible_winner| possible_winner['entry_id'] }
        contenders = standings.select { |entry| entry['hits'] + game_counts.min - entry['games'] >= possible_winners[0]['hits'] }
        contenders.reject! { |contender| entry_ids.include?(contender['entry_id']) }

        if contenders.empty?
          # If no one can possibly catch up then let's declare winners
          possible_winners.select! { |possible_winner| possible_winner['games'] == game_counts.min || possible_winner['possible_winner_game_count'] == game_counts.min }
          possible_winners.each do |possible_winner|
            entry = Entry.find(possible_winner['entry_id'])
            entry.won_at = Time.now
            entry.won_place = place + 1
            entry.save
            winners << entry
          end
        else
          # If someone can catch up, don't declare winners but save the game count on the entry
          possible_winners.each do |possible_winner|
            entry = Entry.find(possible_winner['entry_id'])
            if entry.possible_winner_game_count.nil?
              entry.possible_winner_game_count = possible_winner['games']
              entry.save
            end
          end
        end
      end
    end

    winners
  end

  def losers
    entries.where(won_at: nil)
  end

end
