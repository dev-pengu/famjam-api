class CreateEventOccurrenceExceptions < ActiveRecord::Migration[8.1]
  def change
    create_table :event_occurrence_exceptions, id: :uuid do |t|
      t.references :event, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :occurrence_start_at, null: false # the unmodified UTC start this row overrides
      t.integer :status, null: false, default: 0 # model enum: 0 modified, 1 cancelled

      # Null on any of these means "inherit the parent event's value for this occurrence"
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :title
      t.text :description
      t.string :location
      t.integer :category

      t.references :created_by_user, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :event_occurrence_exceptions, [:event_id, :occurrence_start_at], unique: true,
      name: 'index_occurrence_exceptions_uniqueness'
    add_check_constraint :event_occurrence_exceptions, 'status BETWEEN 0 AND 1',
      name: 'event_occurrence_exceptions_status_check'
    add_check_constraint :event_occurrence_exceptions, 'category IS NULL OR category BETWEEN 0 AND 3',
      name: 'event_occurrence_exceptions_category_check'
  end
end
