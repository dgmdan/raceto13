class AddEndsAtToLeague < ActiveRecord::Migration[4.2]
  def change
    add_column :leagues, :ends_at, :datetime
  end
end
