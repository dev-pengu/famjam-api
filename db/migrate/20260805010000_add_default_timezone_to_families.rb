class AddDefaultTimezoneToFamilies < ActiveRecord::Migration[8.1]
  def change
    add_column :families, :default_timezone, :string # nullable; Family::DEFAULT_TIMEZONE is the fallback
  end
end
