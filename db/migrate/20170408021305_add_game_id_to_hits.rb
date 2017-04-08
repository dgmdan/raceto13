class AddGameIdToHits < ActiveRecord::Migration
  def change
    add_column :hits, :game_id, :integer
  end
end
