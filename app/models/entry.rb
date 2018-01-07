class MaxUserEntriesValidator < ActiveModel::Validator
  def validate(record)
    if Entry.where(user: record.user, league: record.league).active.count >= 5 and !record.user.admin
      record.errors[:base] << 'You have the maximum of 5 entries in this league.'
    end
  end
end

class MaxLeagueEntriesValidator < ActiveModel::Validator
  def validate(record)
    if League.full.include?(record.league)
      record.errors[:base] << 'Entries to this league are sold out.'
    end
  end
end

class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :league
  belongs_to :team, optional: true
  has_many :hits

  include ActiveModel::Validations
  validates_with MaxUserEntriesValidator, MaxLeagueEntriesValidator, on: :create

  scope :active, -> { where(cancelled_at: nil) }
  scope :unassigned, -> { where(team_id: nil) }
  scope :assigned, -> { where.not(team_id: nil) }
  scope :winners, -> { where.not(won_at: nil) }
  scope :losers, -> { where(won_at:nil) }
end
