# app/models/user.rb
class User < ApplicationRecord
  has_many :user_organisations
  has_many :organisations, through: :user_organisations
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :profile, optional: true

  delegate :authorized_for?, to: :profile, allow_nil: true
end