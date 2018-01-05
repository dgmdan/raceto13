class AddStartsAtToLeagues < ActiveRecord::Migration[4.2]
  def change
    add_column :leagues, :starts_at, :datetime
  end
end
