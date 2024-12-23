# app/models/user.rb
class User < ApplicationRecord
  acts_as_tenant(:organization)

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :profile, optional: true

  delegate :authorized_for?, to: :profile, allow_nil: true
end