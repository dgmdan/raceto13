class CreateLeagueUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :league_users do |t|
      t.references :league, index: true
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :league_users, :leagues
    add_foreign_key :league_users, :users
  end
end
