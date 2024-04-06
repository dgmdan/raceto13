# frozen_string_literal: true

class AddUniqueToLeageuser < ActiveRecord::Migration[6.0][5.1]
  def change
    add_index :league_users, %i[user_id league_id], unique: true
  end
end
