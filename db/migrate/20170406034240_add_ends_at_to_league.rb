class AddEndsAtToLeague < ActiveRecord::Migration
  def change
    add_column :leagues, :ends_at, :datetime
  end
end
