class CreateIcalFeedTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :ical_feed_tokens, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      # Stored raw, not hashed, unlike refresh_tokens' token_hash: this isn't
      # a bearer credential for privileged API access, it's a semi-secret
      # subscription link a user pastes into their calendar app and may need
      # to look up again later - it must be re-displayable, not one-time-show.
      t.string :token, null: false
      t.timestamps
    end

    add_index :ical_feed_tokens, :token, unique: true
  end
end
