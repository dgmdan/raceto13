class Team < ActiveRecord::Base
  has_many :team_users

  validates :name, :data_name, presence: true
  validates :data_name, uniqueness: true

  def games
    Game.where(["home_team_id = ? OR away_team_id = ?", id, id])
  end
end
