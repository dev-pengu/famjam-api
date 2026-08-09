# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :context, :record

  def initialize(context, record)
    @context = context
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  private
 
    def membership
      context.membership
    end
  
    def role
      membership&.role
    end
  
    def owner? = role == 'owner'
    def admin? = role == 'admin'
    def adult? = role == 'adult'
    def child? = role == 'child'
  
    def owner_or_admin?
      owner? || admin?
    end
  
    # True if the current user is a registered guardian of the given dependent Person,
    # within the family the policy is scoped to.
    def guardian_of?(person)
      return false unless membership

      context.user.guardianships.exists?(family_id: membership.family_id, dependent_person_id: person.id)
    end

    # Same as guardian_of?, but true if the current user is a registered
    # guardian of ANY of the given people (e.g. any managed participant on a
    # multi-person event), within the family the policy is scoped to.
    def guardian_of_any?(people)
      return false unless membership

      person_ids = Array(people).map(&:id)
      return false if person_ids.empty?

      context.user.guardianships.exists?(family_id: membership.family_id, dependent_person_id: person_ids)
    end

  class Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end
  end
end
