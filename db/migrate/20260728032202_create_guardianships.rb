class CreateGuardianships < ActiveRecord::Migration[8.1]
  def change
    create_table :guardianships, id: :uuid do |t|
      t.references :family, type: :uuid, null: false, foreign_key: true
      t.references :guardian_user, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :dependent_person, type: :uuid, null: false, foreign_key: { to_table: :people }
      t.references :created_by_user, type: :uuid, foreign_key: { to_table: :users }, null: true
      t.timestamps
    end

    add_index :guardianships, [ :family_id, :guardian_user_id, :dependent_person_id ], unique: true, name: 'index_guardianships_uniqueness'
  end
end
