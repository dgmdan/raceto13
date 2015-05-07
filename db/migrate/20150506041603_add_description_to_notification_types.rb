class AddDescriptionToNotificationTypes < ActiveRecord::Migration
  def change
    add_column :notification_types, :description, :string
  end
end
