class League < ActiveRecord::Base
  belongs_to :user
  has_many :league_users
  has_many :users, through: :league_users
  has_many :entries
  has_many :hits, through: :entries

  validates :name, presence: true

  def available_teams
    if self.new_record?
      Team.all
    else
      Team.find_by_sql("SELECT T.id \
                      FROM teams T \
                      LEFT JOIN entries E ON E.team_id = T.id \
                      WHERE E.id IS NULL")
    end

  end

  def registerable?
    # If all of this league's entries have no team_id, teams are not assigned yet so we can say entries are still open.
    entries.where('team_id IS NOT NULL').empty?
  end

  def complete?
    entries.where('won_at IS NOT NULL').any?
  end

  def full?
    entries.active.count == Team.count
  end

  def get_and_record_winners!
    if entries.winners.any?
      # If we already have entries with a won_at date, the winner has already been marked, no need to do it again
      nil
    else
      # Check for potential winners
      winners = []
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
      winners
    end
  end

  def losers
    entries.where(won_at: nil)
  end

end
