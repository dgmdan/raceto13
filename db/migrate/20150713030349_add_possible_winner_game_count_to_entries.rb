# frozen_string_literal: true

class AddPossibleWinnerGameCountToEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :possible_winner_game_count, :integer
  end
end
