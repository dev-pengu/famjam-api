class CreateRewards < ActiveRecord::Migration[8.1]
  def change
    create_table :rewards, id: :uuid do |t|
      t.references :family, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :created_by_user, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :description
      t.integer :coin_cost, null: false
      t.integer :status, null: false # model enum: 0 active, 1 archived
      t.timestamps
    end

    add_check_constraint :rewards, 'coin_cost > 0', name: 'coin_cost_check'
    add_check_constraint :rewards, 'status BETWEEN 0 AND 1',
      name: 'reward_status_check'
  end
end
