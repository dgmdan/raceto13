class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :league_users
  has_many :leagues, through: :league_users
  has_many :entries

  validates :name, presence: true, uniqueness: true

  def to_s
    self.email
  end
end
