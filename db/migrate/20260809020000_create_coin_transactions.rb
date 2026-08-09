class CreateCoinTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :coin_transactions, id: :uuid do |t|
      t.references :membership, type: :uuid, null: false, foreign_key: true
      t.references :created_by_user, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.integer :kind, null: false # model enum: 0 credit, 1 debit
      t.integer :amount, null: false # positive for credit, negative for debit
      t.integer :balance_after, null: false
      t.string :note
      t.timestamps
    end

    add_index :coin_transactions, [ :membership_id, :created_at ]
    add_check_constraint :coin_transactions, 'kind BETWEEN 0 AND 1', name: 'coin_transactions_kind_check'
    add_check_constraint :coin_transactions, 'amount != 0', name: 'coin_transactions_amount_not_zero_check'
    add_check_constraint :coin_transactions, 'balance_after >= 0', name: 'coin_transactions_balance_after_check'
  end
end
