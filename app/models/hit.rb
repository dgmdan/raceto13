class Hit < ApplicationRecord
  belongs_to :entry
  belongs_to :game

  def new?
    self.game.created_at >= Time.now - 24.hours
  end
end
