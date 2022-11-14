class AddWinnerFieldsToLeagues < ActiveRecord::Migration
  def change
    add_column :entries, :won_at, :datetime
  end
end
