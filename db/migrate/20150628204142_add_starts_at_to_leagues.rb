class AddStartsAtToLeagues < ActiveRecord::Migration
  def change
    add_column :leagues, :starts_at, :datetime
  end
end
