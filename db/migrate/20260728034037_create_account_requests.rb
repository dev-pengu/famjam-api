class CreateAccountRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :account_requests, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.integer :kind, null: false # model enum: 0 export, 1 deletion
      t.integer :status, null: false, default: 0 # model enum: 0 pending, 1 processing, 2 completed, 3 failed
      t.datetime :requested_at, null: false
      t.datetime :completed_at
      t.string :download_url # expiring signed URL, export only
      t.timestamps
    end

    add_check_constraint :account_requests, 'kind BETWEEN 0 AND 1', name: 'account_requests_kind_check'
    add_check_constraint :account_requests, 'status BETWEEN 0 AND 3', name: 'account_requests_status_check'
  end
end
