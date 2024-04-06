class AddIndexToTeams < ActiveRecord::Migration[6.0]
  def change
    add_index :teams, :data_name, unique: true
  end
end
