class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  ROLES = %w(customer agent admin)
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  attr_accessor :role

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :generate_authentication_token!
  before_save :assign_role
  validates :auth_token, uniqueness: true
  validates :first_name, :last_name, presence: true
  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :role, presence: true, inclusion: { in: ROLES }

  def assign_role
    self.add_role(role)
  end

  def generate_authentication_token!
    begin
     self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end

  def access_level
    self.roles.first.name
  end

  def admin?
    access_level == 'admin'
  end

  def customer?
    access_level == 'customer'
  end

  def agent?
    access_level == 'agent'
  end
end