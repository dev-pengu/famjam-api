class CoinTransactionSerializer < ApplicationSerializer
  private

  def serialize(coin_transaction)
    {
      id: coin_transaction.id,
      membership_id: coin_transaction.membership_id,
      kind: coin_transaction.kind,
      amount: coin_transaction.amount,
      balance_after: coin_transaction.balance_after,
      note: coin_transaction.note,
      created_by_user_id: coin_transaction.created_by_user_id,
      created_at: coin_transaction.created_at
    }
  end
end
