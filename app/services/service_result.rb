# A small, uniform return value so controllers never have to guess whether a
# service raised, returned nil, or returned the thing itself. Services that
# represent genuine programmer errors (bad arguments, missing records that
# should always exist) still raise — this is for expected, user-facing
# failure paths (bad password, expired invite, locked account, etc.).
class ServiceResult
  attr_reader :data, :errors

  def self.success(data = nil)
    new(success: true, data: data)
  end

  def self.failure(errors)
    new(success: false, errors: errors)
  end

  def initialize(success:, data: nil, errors: [])
    @success = success
    @data = data
    @errors = Array(errors)
  end

  def success? = @success
  def failure? = !@success
end