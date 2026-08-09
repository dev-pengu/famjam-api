class CreateEventReminderDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :event_reminder_deliveries, id: :uuid do |t|
      t.references :event_reminder, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :occurrence_start_at, null: false
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.datetime :sent_at, null: false
    end

    add_index :event_reminder_deliveries, [:event_reminder_id, :occurrence_start_at, :user_id], unique: true,
      name: 'index_reminder_deliveries_uniqueness'
  end
end
