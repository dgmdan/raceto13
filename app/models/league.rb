class League < ActiveRecord::Base
  belongs_to :user
  has_many :league_users
  has_many :users, through: :league_users
  has_many :entries
  has_many :hits, through: :entries

  validates :name, presence: true

  def available_teams
    Team.find_by_sql("SELECT T.id \
                      FROM teams T \
                      LEFT JOIN entries E ON E.team_id = T.id \
                      WHERE E.id IS NULL")
  end

  def registerable?
    entries.where('team_id IS NOT NULL').empty?
  end

  def complete?
    entries.where('won_at IS NOT NULL').any?
  end

  def full?
    entries.active.count == 30
  end

end
