class AddStartsAtToLeagues < ActiveRecord::Migration[6.0]
  def change
    add_column :leagues, :starts_at, :datetime
  end
end
