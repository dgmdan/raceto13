class RenameGameCountField < ActiveRecord::Migration
  def change
    rename_column :entries, :possible_winner_game_count, :game_count
  end
end
