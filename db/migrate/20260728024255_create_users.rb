class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.references :person, type: :uuid, null: false, foreign_key: true, index: { unique: true }
      t.citext :email, null: false
      t.string :password_digest, null: true
      t.datetime :email_verified_at
      t.integer :failed_login_attempts, null: false, default: 0
      t.datetime :locked_at
      t.datetime :last_login_at
      t.datetime :deleted_at, null: true

      t.references :active_family, type: :uuid, foreign_key: { to_table: :families }, null: true

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
