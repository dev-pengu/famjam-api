# Plain POROs, not a gem dependency - `render json: SomeSerializer.new(record)`
# works because ActiveSupport's #to_json calls #as_json if it's defined, and
# Rails' `render json:` ultimately calls #to_json on whatever you pass it.
#
# This is the one place columns get explicitly chosen to expose - never
# `render json: some_active_record_object` directly anywhere in a
# controller, or you risk leaking password_digest, token hashes, etc. the
# moment someone adds a column.
class ApplicationSerializer
  def initialize(object)
    @object = object
  end

  def as_json(*)
    if enumerable?
      @object.map { |item| self.class.new(item).as_json }
    else
      serialize(@object)
    end
  end

  private

  def enumerable?
    @object.respond_to?(:each) && !@object.is_a?(ActiveRecord::Base)
  end

  def serialize(_record)
    raise NotImplementedError, "#{self.class} must implement #serialize"
  end
end
