class PersonUpdateParams < ApplicationParams
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :nickname, :string

  validate :at_least_one_field_present

  def any_changes?
    first_name.present? || last_name.present? || nickname.present?
  end

  private

  def at_least_one_field_present
    errors.add(:base, "must include at least one field to update") unless any_changes?
  end
end
