# frozen_string_literal: true

class Team < ApplicationRecord
  validates :name, :data_name, presence: true
  validates :data_name, uniqueness: true

  has_many :games

  def games
    Game.where(['home_team_id = ? OR away_team_id = ?', id, id])
  end
end
