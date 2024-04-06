class CreateTeamUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :team_users do |t|
      t.references :team, index: true
      t.references :user, index: true
      t.references :league, index: true

      t.timestamps null: false
    end
    add_foreign_key :team_users, :teams
    add_foreign_key :team_users, :users
    add_foreign_key :team_users, :leagues
  end
end
