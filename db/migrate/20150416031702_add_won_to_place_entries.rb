class AddWonToPlaceEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :entries, :won_place, :integer, after: :won_at
  end
end
