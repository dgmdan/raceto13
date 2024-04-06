# frozen_string_literal: true

class AddDescriptionToNotificationTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :notification_types, :description, :string
  end
end
