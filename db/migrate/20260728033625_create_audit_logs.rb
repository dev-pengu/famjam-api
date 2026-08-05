class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.references :family, type: :uuid, foreign_key: true, null: true # null = account-level action
      t.references :actor_user, type: :uuid, foreign_key: { to_table: :users }, null: true # null = system action
      t.string :action, null: false
      t.string :target_type
      t.uuid :target_id
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end

    add_index :audit_logs, [:target_type, :target_id]
    add_index :audit_logs, :action
  end
end
