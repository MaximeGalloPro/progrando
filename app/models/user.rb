# frozen_string_literal: true

# Represents a user account in the system with authentication capabilities
# and associations with organisations and members
class User < ApplicationRecord
    has_many :user_organisations, dependent: :destroy
    has_many :organisations, through: :user_organisations
    has_many :user_members, dependent: :destroy
    has_many :members, through: :user_members

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable

    belongs_to :profile, optional: true

    delegate :authorized_for?, to: :profile, allow_nil: true
end
