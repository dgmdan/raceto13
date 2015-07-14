class AddPossibleWinnerGameCountToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :game_count, :integer
  end
end
