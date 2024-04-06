class AddEndsAtToLeague < ActiveRecord::Migration[6.0]
  def change
    add_column :leagues, :ends_at, :datetime
  end
end
