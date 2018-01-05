class AddIndexToTeams < ActiveRecord::Migration[4.2]
  def change
    add_index :teams, :data_name, unique: true
  end
end
