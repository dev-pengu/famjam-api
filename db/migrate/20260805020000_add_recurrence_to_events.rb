class AddRecurrenceToEvents < ActiveRecord::Migration[8.1]
  def change
    change_table :events do |t|
      t.integer :recurrence_frequency # model enum: 0 daily, 1 weekly, 2 monthly, 3 yearly; null = one-off event
      t.integer :recurrence_interval, default: 1
      t.string :recurrence_byday, array: true, default: [] # weekly only, RRULE codes e.g. ['TU']
      t.date :recurrence_until # inclusive series end date, in the event's timezone; null = open-ended
    end

    add_check_constraint :events, 'recurrence_frequency IS NULL OR recurrence_frequency BETWEEN 0 AND 3',
      name: 'events_recurrence_frequency_check'
  end
end
