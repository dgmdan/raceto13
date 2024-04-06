class AddWinnerFieldsToLeagues < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :won_at, :datetime
  end
end
