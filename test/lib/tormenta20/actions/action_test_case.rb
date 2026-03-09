# frozen_string_literal: true

require_relative "../operations/operation_test_case"

# Shared helpers for action integration tests.
# Reuses OperationTestCase since actions wrap operations and have the same DB requirements.
# Actions return Operation results directly, so the same unwrap_result helpers apply.
module ActionTestCase
  include OperationTestCase
end
