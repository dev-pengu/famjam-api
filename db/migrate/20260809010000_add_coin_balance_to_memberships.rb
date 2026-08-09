class AddCoinBalanceToMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :memberships, :coin_balance, :integer, null: false, default: 0
    add_check_constraint :memberships, 'coin_balance >= 0', name: 'memberships_coin_balance_check'
  end
end
