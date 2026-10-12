class ChoreSearchQuery
  SORTS = %w[due_date newest coins_desc coins_asc assignee].freeze
  DEFAULT_SORT = "due_date"

  def self.call(family:, **kwargs)
    new(family: family, **kwargs).call
  end

  def initialize(family:, assignee_id: nil, category: nil, coin_min: nil, coin_max: nil, search: nil, sort: nil)
    @family = family
    @assignee_id = assignee_id
    @category = category
    @coin_min = coin_min.presence&.to_i
    @coin_max = coin_max.presence&.to_i
    @search = search
    @sort = SORTS.include?(sort) ? sort : DEFAULT_SORT
  end

  def call
    apply_sort(apply_filters(base_scope))
  end

  private

  def base_scope
    @family.chores.active.includes(assignee: :person)
  end

  def apply_filters(scope)
    scope = filter_by_assignee(scope)
    scope = scope.where(category: @category) if Chore.categories.key?(@category)
    scope = scope.where(coin_value: @coin_min..) if @coin_min
    scope = scope.where(coin_value: ..@coin_max) if @coin_max
    scope = filter_by_search(scope)
    scope
  end

  def filter_by_assignee(scope)
    return scope.where(assignee_id: nil) if @assignee_id == "unassigned"
    return scope.where(assignee_id: @assignee_id) if @assignee_id.present?

    scope
  end

  def filter_by_search(scope)
    return scope if @search.blank?

    term = "%#{ActiveRecord::Base.sanitize_sql_like(@search)}%"
    scope.where("chores.title ILIKE :term OR chores.description ILIKE :term", term: term)
  end

  def apply_sort(scope)
    case @sort
    when "newest" then scope.order(created_at: :desc)
    when "coins_desc" then scope.order(coin_value: :desc)
    when "coins_asc" then scope.order(coin_value: :asc)
    when "assignee" then sort_by_assignee(scope)
    else scope.order(:starts_on)
    end
  end

  # Unassigned chores first, regardless of name; assigned chores then sorted
  # by the assignee's display name (nickname if set, else first name).
  def sort_by_assignee(scope)
    scope
      .left_joins(assignee: :person)
      .order(Arel.sql("(chores.assignee_id IS NULL) DESC, COALESCE(NULLIF(people.nickname, ''), people.first_name) ASC"))
  end
end
