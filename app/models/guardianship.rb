class Guardianship < ApplicationRecord
  belongs_to :family
  belongs_to :guardian_user, class_name: 'User', inverse_of: :guardianships
  belongs_to :dependent_person, class_name: 'Person', inverse_of: :guardianships
  belongs_to :created_by_user, class_name: 'User', optional: true

  validates :guardian_user_id, uniqueness: { scope: %i[family_id dependent_person_id] }
  validate :dependent_must_be_a_managed_child

  private
    def dependent_must_be_a_managed_child
      return unless dependent_person

      unless dependent_person.managed?
        errors.add(:dependent_person, 'must not have their own login')
      end

      membership = family&.memberships&.find_by(person_id: dependent_person_id)
      errors.add(:dependent_person, 'must be a child member of this family') unless membership&.child?
    end
end