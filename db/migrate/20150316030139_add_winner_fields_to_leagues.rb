class AddWinnerFieldsToLeagues < ActiveRecord::Migration[4.2]
  def change
    add_column :entries, :won_at, :datetime
  end
end
