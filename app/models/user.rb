# frozen_string_literal: true

require 'digest/md5'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :league_users
  has_many :leagues, through: :league_users
  has_many :owned_leagues, foreign_key: 'user_id', class_name: 'League'
  has_many :entries
  has_many :notification_type_users
  has_many :notification_types, through: :notification_type_users

  validates :name, presence: true, uniqueness: true

  def to_s
    email
  end

  def admin?
    admin == true
  end

  def gravatar_url
    email_address = email.downcase
    hash = Digest::MD5.hexdigest(email_address)
    "http://www.gravatar.com/avatar/#{hash}"
  end
end
