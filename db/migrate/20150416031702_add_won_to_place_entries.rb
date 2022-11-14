class AddWonToPlaceEntries < ActiveRecord::Migration
  def change
    add_column :entries, :won_place, :integer, after: :won_at
  end
end
