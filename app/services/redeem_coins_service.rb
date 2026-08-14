class RedeemCoinsService < ApplicationService
  def initialize(actor:, membership:, amount:, note: nil)
    @actor = actor
    @membership = membership
    @amount = amount
    @note = note
  end

  def call
    entry = nil

    ActiveRecord::Base.transaction(requires_new: true) do
      @membership.lock!
      entry = @membership.coin_transactions.create!(
        kind: :debit, amount: -@amount.abs, note: @note, created_by_user: @actor,
      )
      @membership.update!(coin_balance: entry.balance_after)
    end

    ServiceResult.success(entry)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
