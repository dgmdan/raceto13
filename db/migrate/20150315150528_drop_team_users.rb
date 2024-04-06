# frozen_string_literal: true

class DropTeamUsers < ActiveRecord::Migration[6.0]
  def change
    drop_table :team_users
  end
end
