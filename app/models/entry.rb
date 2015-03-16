class LeagueSizeValidator < ActiveModel::Validator
  def validate(record)
    if record.league.entries.active.count == 30
      record.errors[:base] << 'Entries are sold out.'
    end
  end
end

class MaxEntriesValidator < ActiveModel::Validator
  def validate(record)
    if Entry.where(user: record.user).active.count == 5
      record.errors[:base] << 'You have the maximum of 5 entries.'
    end
  end
end

class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  belongs_to :team

  include ActiveModel::Validations
  validates_with LeagueSizeValidator, MaxEntriesValidator

  scope :active, -> { where(cancelled_at: nil) }
end
