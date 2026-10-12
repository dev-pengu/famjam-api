class AddCategoryToChores < ActiveRecord::Migration[8.1]
  def change
    add_column :chores, :category, :integer # model enum: 0 household, 1 outdoor, 2 pet_care, 3 personal_care, 4 homework, 5 other; null = uncategorized

    add_check_constraint :chores, "category IS NULL OR category BETWEEN 0 AND 5", name: "chores_category_check"
  end
end
