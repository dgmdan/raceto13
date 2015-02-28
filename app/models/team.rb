class Team < ActiveRecord::Base
  validates :name, :data_name, presence: true
  validates :data_name, uniqueness: true
end
