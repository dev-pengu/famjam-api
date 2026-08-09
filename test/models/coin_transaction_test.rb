require "test_helper"

class CoinTransactionTest < ActiveSupport::TestCase
  setup do
    @membership = memberships(:sam_child_smith)
    @membership.update!(coin_balance: 10)
    @actor = users(:lazaro_nixon)
  end

  def build_transaction(**overrides)
    CoinTransaction.new({
      membership: @membership, created_by_user: @actor
    }.merge(overrides))
  end

  test "valid credit sets balance_after to membership balance plus amount" do
    txn = build_transaction(kind: :credit, amount: 5)
    assert txn.valid?
    txn.save!
    assert_equal 15, txn.balance_after
  end

  test "valid debit within balance sets balance_after to membership balance minus amount" do
    txn = build_transaction(kind: :debit, amount: -4, note: "Ice cream trip")
    assert txn.valid?
    txn.save!
    assert_equal 6, txn.balance_after
  end

  test "invalid when a credit amount is not positive" do
    txn = build_transaction(kind: :credit, amount: -5)
    assert_not txn.valid?
    assert_includes txn.errors[:amount], "must be positive for a credit"
  end

  test "invalid when a debit amount is not negative" do
    txn = build_transaction(kind: :debit, amount: 5, note: "oops")
    assert_not txn.valid?
    assert_includes txn.errors[:amount], "must be negative for a debit"
  end

  test "invalid when a debit would push the balance below zero" do
    txn = build_transaction(kind: :debit, amount: -11, note: "Too much")
    assert_not txn.valid?
    assert_includes txn.errors[:amount], "exceeds available coin balance"
  end

  test "invalid when a debit has no note" do
    txn = build_transaction(kind: :debit, amount: -1, note: nil)
    assert_not txn.valid?
    assert_includes txn.errors[:note], "can't be blank"
  end

  test "invalid with a zero amount" do
    txn = build_transaction(kind: :credit, amount: 0)
    assert_not txn.valid?
  end
end
