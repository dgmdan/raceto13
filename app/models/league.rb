class League < ActiveRecord::Base
  belongs_to :user
  has_many :league_users
  has_many :users, through: :league_users

  validates :name, presence: true

  def teams
    # Team.joins(:team_users)
    nil
  end
end
