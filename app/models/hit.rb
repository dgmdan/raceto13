class Hit < ActiveRecord::Base
  belongs_to :entry
  belongs_to :game
end
