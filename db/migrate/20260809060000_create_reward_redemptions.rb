class CreateRewardRedemptions < ActiveRecord::Migration[8.1]
  def change
    create_table :reward_redemptions, id: :uuid do |t|
      t.references :reward, type: :uuid, null: false, foreign_key: true
      t.references :claimee, type: :uuid, null: false, foreign_key: { to_table: :memberships }
      t.integer :coin_cost, null: false # snapshot of reward.coin_cost at request time
      t.integer :status, null: false # model enum: 0 pending_approval, 1 approved, 2 denied, 3 cancelled
      t.date :requested_at, null: false
      t.references :reviewed_by_user, type: :uuid, foreign_key: { to_table: :users }
      t.date :reviewed_at
      t.string :denial_reason
      t.references :coin_transaction, type: :uuid, foreign_key: { to_table: :coin_transactions } # set only on approval
      t.timestamps
    end

    add_check_constraint :reward_redemptions, 'status BETWEEN 0 AND 3',
      name: 'reward_redemption_status_check'
  end
end
