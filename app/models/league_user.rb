class LeagueUser < ActiveRecord::Base
  belongs_to :league
  belongs_to :user
end
