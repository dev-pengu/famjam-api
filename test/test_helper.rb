ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Process-based parallelization forks worker processes after Rails has
  # already opened a DB connection, which isn't fork-safe with libpq and
  # segfaults in some sandboxed/CI environments. The suite runs in ~2s even
  # serially at this size, so it's not worth chasing a fork-safe setup.
  parallelize(workers: 1)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def sign_in_as(user)
    post(sign_in_url, params: { email: user.email, password: "Secret1*3*5*" }); [ user, response.headers["X-Session-Token"] ]
  end
end
