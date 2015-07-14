class RenameGameCountField < ActiveRecord::Migration
  def change
    rename_column :entries, :game_count, :game_count
  end
end
