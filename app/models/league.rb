class League < ActiveRecord::Base
  belongs_to :user
  has_many :league_users
  has_many :users, through: :league_users
  has_many :team_users

  validates :name, presence: true

  def teams
    Team.joins(:team_users)
  end
end
