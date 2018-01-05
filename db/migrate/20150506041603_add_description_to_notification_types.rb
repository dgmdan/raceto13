class AddDescriptionToNotificationTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :notification_types, :description, :string
  end
end
