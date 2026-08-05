class Person < ApplicationRecord
  has_one :user, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :families, through: :memberships
  has_many :guardianships, foreign_key: :dependent_person_id, inverse_of: :dependent_person, dependent: :destroy
  has_many :guardians, through: :guardianships, source: :guardian_user

  validates :first_name, :last_name, presence: true

  def display_name
    nickname.presence || first_name
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def managed?
    user.nil?
  end
end