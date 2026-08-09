class CreateIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :identities, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.integer :provider, null: false, default: 0 # 0 = google
      t.string :provider_uid, null: false
      t.timestamps
    end

    add_index :identities, [ :provider, :provider_uid ], unique: true
  end
end
