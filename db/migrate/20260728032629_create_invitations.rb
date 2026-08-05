class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations, id: :uuid do |t|
      t.references :family, type: :uuid, null: false, foreign_key: true
      t.string :code, null: false
      t.integer :role, null: false # model enum: 1 admin, 2 adult, 3 child — never 0/owner
      t.references :created_by_user, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.citext :email # optional — restricts redemption to a specific address
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.datetime :used_at
      t.references :used_by_person, type: :uuid, foreign_key: { to_table: :people }, null: true
      t.timestamps
    end

    add_index :invitations, :code, unique: true
    add_check_constraint :invitations, 'role BETWEEN 1 AND 3', name: 'invitations_role_check'
  end
end
