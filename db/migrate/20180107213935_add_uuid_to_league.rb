class AddUuidToLeague < ActiveRecord::Migration[6.0][5.1]
  def change
    add_column :leagues, :invite_uuid, :string
    add_index :leagues, :invite_uuid
  end
end
