class CreateNotificationTypeUsers < ActiveRecord::Migration
  def change
    create_table :notification_type_users do |t|
      t.references :notification_type
      t.references :user

      t.timestamps null: false
    end
  end
end
