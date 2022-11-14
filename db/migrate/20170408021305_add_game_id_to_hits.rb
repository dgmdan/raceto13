class AddGameIdToHits < ActiveRecord::Migration
  def change
    add_reference :hits, :game
  end
end
