# frozen_string_literal: true

require_relative "auth_operation_test_case"

class Auth::Operations::ConfirmEmailTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    @user = create_user(email: "confirm_#{SecureRandom.hex(4)}@example.com", password: "password123")
    # Devise skip_confirmation! is not available without :confirmable in routes;
    # generate a real token instead
    @raw_token = @user.send_confirmation_instructions
  end

  test "confirms user with valid token" do
    result = Auth::Operations::ConfirmEmail.new.call(token: @raw_token)
    value = success!(result)
    assert value[:user]
    assert value[:tokens][:access_token]
    @user.reload
    assert @user.confirmed?
  end

  test "fails with invalid token" do
    result = Auth::Operations::ConfirmEmail.new.call(token: "badtoken")
    failure!(result, :invalid_token)
  end

  test "fails when token already used" do
    @user.send_confirmation_instructions
    User.confirm_by_token(@raw_token) # consume it
    result = Auth::Operations::ConfirmEmail.new.call(token: @raw_token)
    failure!(result, :invalid_token)
  end
end
