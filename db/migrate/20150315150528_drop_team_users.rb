class DropTeamUsers < ActiveRecord::Migration[4.2]
  def change
    drop_table :team_users
  end
end
