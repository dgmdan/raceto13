class League < ActiveRecord::Base
  belongs_to :user
  has_many :league_users
  has_many :users, through: :league_users
  has_many :entries
  has_many :hits, through: :entries

  validates :name, :starts_at, presence: true

  scope :started, -> { where('starts_at <= ?', Time.now)  }
  scope :full, -> { joins(:entries).where('entries.cancelled_at IS NULL').group('leagues.id').having('COUNT(entries.id) = ?', Team.count) }
  scope :complete, -> { joins(:entries).where('entries.won_at IS NOT NULL').group('leagues.id') }

  def available_teams
    Team.all - entries.active.map(&:team)
  end

  def get_and_record_winners!
    winners = []
    unless entries.winners.any?
      # Check for potential winners
      winner_sql = "SELECT entry_id FROM hits JOIN entries ON entries.id = hits.entry_id WHERE entries.league_id = #{id} GROUP BY hits.entry_id HAVING COUNT(hits.id) >= 14"
      winner_entry_ids = ActiveRecord::Base.connection.execute(winner_sql).collect{|x| x['entry_id']}
      if winner_entry_ids.size >= 1
        # We have a winner (or more than one)
        winner_entry_ids.each do |entry_id|
          entry = Entry.find(entry_id)
          entry.won_at = Time.now
          entry.won_place = 1
          entry.save
          winners << entry
        end

        # Determine second place prize
        second_place_sql = "SELECT entry_id FROM hits JOIN entries ON entries.id = hits.entry_id WHERE entries.league_id = #{id} GROUP BY hits.entry_id HAVING COUNT(hits.id) = 13"
        second_place_entry_ids = ActiveRecord::Base.connection.execute(second_place_sql).collect{|x| x['entry_id']}
        second_place_entry_ids.each do |entry_id|
          entry = Entry.find(entry_id)
          entry.won_at = Time.now
          entry.won_place = 2
          entry.save
          winners << entry
        end
      end
    end
    winners
  end

  def losers
    entries.where(won_at: nil)
  end

end
