class NotificationTypeUser < ActiveRecord::Base
  belongs_to :notification_type
  belongs_to :user
end
