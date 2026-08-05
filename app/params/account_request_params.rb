class AccountRequestParams < ApplicationParams
  attribute :kind, :string

  validates :kind, presence: true, inclusion: { in: %w[export deletion] }
end
