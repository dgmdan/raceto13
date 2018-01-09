class LeagueUser < ApplicationRecord
  belongs_to :league
  belongs_to :user

  validates_uniqueness_of :league, scope: :user
end
