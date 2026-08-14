class CreateChores < ActiveRecord::Migration[8.1]
  def change
    create_table :chores, id: :uuid do |t|
      t.references :family, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :assignee, type: :uuid, null: false, foreign_key: { to_table: :memberships }
      t.references :created_by_user, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :title
      t.string :description
      t.integer :coin_value
      t.integer :status, null: false # model enum: 0 active, 1 archived
      t.datetime :starts_on
      t.integer :recurrence_frequency # model enum: 0 daily, 1 weekly, 2 monthly, 3 yearly; null = one-off assignment
      t.integer :recurrence_interval, default: 1
      t.string :recurrence_byday, array: true, default: [] # weekly only, RRULE codes e.g. ['TU']
      t.date :recurrence_until # inclusive series end date, in the chore's timezone; null = open-ended
      t.timestamps
    end

    add_check_constraint :chores, 'coin_value >= 0', name: 'coin_value_check'
    add_check_constraint :chores, 'recurrence_frequency IS NULL OR recurrence_frequency BETWEEN 0 AND 3',
      name: 'chores_recurrence_frequency_check'
  end
end
