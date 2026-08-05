class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :family, type: :uuid, null: false, foreign_key: true
      t.references :person, type: :uuid, null: false, foreign_key: true
      t.integer :role, null: false  # model enum: 0 owner, 1 admin, 2 adult, 3 child
      t.integer :status, null: false, default: 0 # model enum: 0 active, 1 left, 2 removed
      t.references :invited_by_user, type: :uuid, foreign_key: { to_table: :users }, null: true
      t.datetime :joined_at
      t.datetime :left_at
      t.datetime :removed_at
      t.timestamps
    end

    add_index :memberships, [:family_id, :person_id], unique: true

    # DB-enforced invariant: at most one ACTIVE owner per family, regardless of app-layer bugs.
    add_index :memberships, :family_id,
      unique: true,
      where: 'role = 0 and status = 0',
      name: 'index_memberships_on_single_active_owner_per_family'

    add_check_constraint :memberships, 'role BETWEEN 0 AND 3', name: 'memberships_role_check'
    add_check_constraint :memberships, 'status BETWEEN 0 AND 2', name: 'memberships_status_check'
  end
end
