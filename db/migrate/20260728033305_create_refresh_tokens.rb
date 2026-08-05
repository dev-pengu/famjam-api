class CreateRefreshTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :refresh_tokens, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :token_hash, null: false
      t.string :device_name
      t.string :user_agent
      t.string :ip_address
      t.datetime :last_used_at
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end

    add_index :refresh_tokens, :token_hash, unique: true
  end
end
