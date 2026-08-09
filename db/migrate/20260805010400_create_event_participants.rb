class CreateEventParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :event_participants, id: :uuid do |t|
      t.references :event, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :person, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end

    add_index :event_participants, [ :event_id, :person_id ], unique: true
  end
end
