class RenameGameCountField < ActiveRecord::Migration[4.2]
  def change
    rename_column :entries, :possible_winner_game_count, :game_count
  end
end
