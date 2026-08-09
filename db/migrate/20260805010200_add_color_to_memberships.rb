class AddColorToMemberships < ActiveRecord::Migration[8.1]
  def up
    add_column :memberships, :color, :integer, null: false, default: 0 # model enum: 0 red..11 pink, see Membership
    add_check_constraint :memberships, 'color BETWEEN 0 AND 11', name: 'memberships_color_check'

    # Existing rows all default to color 0 above; assign round-robin colors
    # per family (ordered by creation) so pre-existing members don't all
    # render as the same color.
    execute(<<~SQL.squish)
      WITH ranked AS (
        SELECT id, (ROW_NUMBER() OVER (PARTITION BY family_id ORDER BY created_at) - 1) % 12 AS rank
        FROM memberships
      )
      UPDATE memberships
      SET color = ranked.rank
      FROM ranked
      WHERE memberships.id = ranked.id
    SQL
  end

  def down
    remove_check_constraint :memberships, name: 'memberships_color_check'
    remove_column :memberships, :color
  end
end
