# frozen_string_literal: true

class NotificationTypeUser < ApplicationRecord
  belongs_to :notification_type
  belongs_to :user
end
