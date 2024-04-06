# frozen_string_literal: true

class Hit < ApplicationRecord
  belongs_to :entry
  belongs_to :game

  def new?
    game.created_at >= Time.now - 24.hours
  end
end
