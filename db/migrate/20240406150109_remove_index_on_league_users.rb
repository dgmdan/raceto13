class RemoveIndexOnLeagueUsers < ActiveRecord::Migration[7.1]
  def change
    remove_index :league_users, name: 'index_league_users_on_user_id_and_league_id'
  end
end
