class AddPossibleWinnerGameCountToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :possible_winner_game_count, :integer
  end
end
