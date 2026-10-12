class MakeChoresAssigneeOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :chores, :assignee_id, true
  end
end
