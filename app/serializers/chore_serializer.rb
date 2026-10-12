class ChoreSerializer < ApplicationSerializer
  private

  def serialize(chore)
    {
      id: chore.id,
      family_id: chore.family_id,
      assignee_id: chore.assignee_id,
      assignee: chore.assignee && MembershipSerializer.new(chore.assignee).as_json,
      created_by_user_id: chore.created_by_user_id,
      title: chore.title,
      description: chore.description,
      category: chore.category,
      category_color: chore.category_color,
      coin_value: chore.coin_value,
      status: chore.status,
      starts_on: chore.starts_on,
      recurrence_frequency: chore.recurrence_frequency,
      recurrence_interval: chore.recurrence_interval,
      recurrence_byday: chore.recurrence_byday,
      recurrence_until: chore.recurrence_until,
      created_at: chore.created_at
    }
  end
end
