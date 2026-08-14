class CreateChoreCompletions < ActiveRecord::Migration[8.1]
  def change
    create_table :chore_completions, id: :uuid do |t|
      t.references :chore, type: :uuid, null: false, foreign_key: true
      t.date :due_on
      t.references :completed_by_membership, type: :uuid, null: false, foreign_key: { to_table: :memberships }
      t.date :completed_at
      t.integer :coin_value, null: false # snapshot of chore.coin_value at completion time so editing later doesn't change what a pending approval pays out
      t.integer :status, null: false # model enum: 0 pending_approval, 1 approved, 2 rejected
      t.references :reviewed_by_user, type: :uuid, foreign_key: { to_table: :users }
      t.date :reviewed_at
      t.string :rejection_reason
      t.references :coin_transaction, type: :uuid, foreign_key: { to_table: :coin_transactions } # set only on approval
      t.timestamps
    end

    add_index :chore_completions, [ :chore_id, :due_on ], unique: true
    add_check_constraint :chore_completions, 'status BETWEEN 0 AND 2',
      name: 'chores_completion_status_check'
  end
end
