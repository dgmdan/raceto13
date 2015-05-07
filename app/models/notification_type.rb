class NotificationType < ActiveRecord::Base
  has_many :notification_type_users
end
