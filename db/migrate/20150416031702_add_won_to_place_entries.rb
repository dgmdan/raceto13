# frozen_string_literal: true

class AddWonToPlaceEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :won_place, :integer, after: :won_at
  end
end
