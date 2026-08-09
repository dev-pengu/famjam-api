class AddTimezoneToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :timezone, :string # nullable; falls back to family default, then Family::DEFAULT_TIMEZONE
  end
end
