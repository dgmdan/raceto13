# frozen_string_literal: true

class NotificationType < ApplicationRecord
  has_many :notification_type_users
end
