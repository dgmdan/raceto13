class AddPossibleWinnerGameCountToEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :entries, :possible_winner_game_count, :integer
  end
end
