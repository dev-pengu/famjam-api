class RewardUpdateParams < ApplicationParams
  attribute :title, :string
  attribute :description, :string
  attribute :coin_cost, :integer

  validates :coin_cost, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  validate :at_least_one_field_present

  def any_changes?
    title.present? || description.present? || coin_cost.present?
  end

  private

  def at_least_one_field_present
    errors.add(:base, "must include at least one field to update") unless any_changes?
  end
end
