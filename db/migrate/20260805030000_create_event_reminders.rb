class CreateEventReminders < ActiveRecord::Migration[8.1]
  def change
    create_table :event_reminders, id: :uuid do |t|
      t.references :event, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, type: :uuid, foreign_key: true, null: true # null = applies to every participant; set = one user's override/addition
      t.integer :minutes_before, null: false
      t.timestamps
    end

    add_index :event_reminders, [:event_id, :user_id]
    add_check_constraint :event_reminders, 'minutes_before > 0', name: 'event_reminders_minutes_before_check'
  end
end
