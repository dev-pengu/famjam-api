class CreatePeople < ActiveRecord::Migration[8.1]
  def change
    create_table :people, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :nickname
      t.timestamps
    end
  end
end
