class CreateFamilies < ActiveRecord::Migration[8.1]
  def change
    create_table :families, id: :uuid do |t|
      t.string :name, null: false
      t.integer :invitation_ttl_hours # family level override for invitation ttl
      t.timestamps
    end
  end
end
