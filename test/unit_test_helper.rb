# frozen_string_literal: true

# Minimal test helper for pure unit tests that don't require database access.
# Use this instead of test_helper.rb in pipeline pipe tests and other isolated units.
ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "minitest/autorun"
require "active_support/test_case"

# Disable DB connection attempt by not calling fixtures :all
# and by not loading rails/test_help (which calls maintain_test_schema!)
ActiveSupport::TestCase.test_order = :random
