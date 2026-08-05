class EnableExtensions < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'pgcrypto' # gen_random_uuid()
    enable_extension 'citext'   # case-insensitive email columns
  end
end
