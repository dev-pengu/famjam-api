class CreateNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_preferences, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.integer :notification_type, null: false # model enum: 0 event_reminder, 1 event_invited, 2 event_updated, 3 event_cancelled, 4 agenda_email
      t.boolean :enabled, null: false, default: true
      t.timestamps
    end

    add_index :notification_preferences, [:user_id, :notification_type], unique: true
    add_check_constraint :notification_preferences, 'notification_type BETWEEN 0 AND 4',
      name: 'notification_preferences_type_check'
  end
end
