class DestroyEventService < ApplicationService
  def initialize(event:)
    @event = event
  end

  def call
    @event.destroy!
    ServiceResult.success(true)
  end
end
