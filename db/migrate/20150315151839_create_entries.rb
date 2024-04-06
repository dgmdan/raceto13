# frozen_string_literal: true

class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries do |t|
      t.references :user, index: true
      t.references :league, index: true
      t.references :team, index: true
      t.datetime :paid_at
      t.datetime :cancelled_at

      t.timestamps null: false
    end
    add_foreign_key :entries, :users
    add_foreign_key :entries, :leagues
    add_foreign_key :entries, :teams
  end
end
