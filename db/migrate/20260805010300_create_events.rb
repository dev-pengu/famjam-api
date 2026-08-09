class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events, id: :uuid do |t|
      t.references :family, type: :uuid, null: false, foreign_key: true
      t.references :created_by_user, type: :uuid, null: false, foreign_key: { to_table: :users }

      t.string :title, null: false
      t.text :description
      t.string :location
      t.integer :category # model enum: 0 school, 1 practice_sports, 2 medical, 3 travel; null = uncategorized
      t.string :timezone, null: false
      t.boolean :all_day, null: false, default: false

      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false

      t.timestamps
    end

    add_index :events, [:family_id, :starts_at]
    add_check_constraint :events, 'ends_at >= starts_at', name: 'events_ends_after_starts_check'
    add_check_constraint :events, 'category IS NULL OR category BETWEEN 0 AND 3', name: 'events_category_check'
  end
end
