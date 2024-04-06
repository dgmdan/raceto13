class AddGameIdToHits < ActiveRecord::Migration[6.0]
  def change
    add_reference :hits, :game
  end
end
