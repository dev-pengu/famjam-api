class CreateAgendaSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :agenda_subscriptions, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :family, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.integer :scope, null: false, default: 0 # model enum: 0 mine, 1 whole_family
      t.integer :interval_days, null: false, default: 7 # generic cadence: 1=daily, 7=weekly, 14=biweekly, 30=monthly, or custom
      t.integer :send_hour_local, null: false, default: 7 # 0-23, in the user's resolved display timezone
      t.date :anchor_date, null: false # set at creation; due-check is (today - anchor_date) % interval_days == 0
      t.boolean :enabled, null: false, default: true
      t.datetime :last_sent_at
      t.timestamps
    end

    add_index :agenda_subscriptions, [ :enabled, :interval_days ]
    add_check_constraint :agenda_subscriptions, 'interval_days > 0', name: 'agenda_subscriptions_interval_days_check'
    add_check_constraint :agenda_subscriptions, 'send_hour_local BETWEEN 0 AND 23',
      name: 'agenda_subscriptions_send_hour_check'
    add_check_constraint :agenda_subscriptions, 'scope BETWEEN 0 AND 1', name: 'agenda_subscriptions_scope_check'
  end
end
