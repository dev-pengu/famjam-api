class AwardCoinsService < ApplicationService
  def initialize(actor:, membership:, amount:, note: nil)
    @actor = actor
    @membership = membership
    @amount = amount
    @note = note
  end

  def call
    entry = nil

    ActiveRecord::Base.transaction do
      @membership.lock!
      entry = @membership.coin_transactions.create!(
        kind: :credit, amount: @amount, note: @note, created_by_user: @actor,
      )
      @membership.update!(coin_balance: entry.balance_after)
    end

    ServiceResult.success(entry)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
