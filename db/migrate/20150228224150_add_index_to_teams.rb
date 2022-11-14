class AddIndexToTeams < ActiveRecord::Migration
  def change
    add_index :teams, :data_name, unique: true
  end
end
