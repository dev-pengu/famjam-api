# Base for request-param validation objects. Subclasses declare their shape
# with ActiveModel::Attributes (typed, so "5" becomes 5 for an :integer
# attribute) and validate with normal ActiveModel::Validations.
#
# `.build(params)` IS the whitelist: only declared attributes are ever pulled
# out of the incoming params, so there's no separate strong-params `permit`
# list to keep in sync with this file. Anything not declared here is
# silently ignored, not raised on - keeps this safe to call with a raw
# ActionController::Parameters or a plain hash.
class ApplicationParams
  include ActiveModel::Model
  include ActiveModel::Attributes

  UUID_REGEXP = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

  def self.build(raw_params)
    source = raw_params.respond_to?(:to_unsafe_h) ? raw_params.to_unsafe_h : raw_params.to_h
    attrs = source.symbolize_keys.slice(*attribute_names.map(&:to_sym))
    new(attrs)
  end

  # Attributes as a plain hash, ready to splat into a service call, e.g.
  # SomeService.call(**contract.to_service_args)
  def to_service_args
    attributes.symbolize_keys
  end
end
