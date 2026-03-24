# frozen_string_literal: true

require_relative "auth_operation_test_case"

class Auth::Operations::ResetPasswordTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    @user = create_user(email: "reset_#{SecureRandom.hex(4)}@example.com", password: "oldpassword1")
    @raw_token = @user.send_reset_password_instructions
  end

  test "resets password with valid token" do
    result = Auth::Operations::ResetPassword.new.call(
      token: @raw_token,
      password: "newpassword1",
      password_confirmation: "newpassword1"
    )
    value = success!(result)
    assert value[:user]
    assert value[:tokens][:access_token]
    @user.reload
    assert @user.valid_password?("newpassword1")
  end

  test "fails with invalid token" do
    result = Auth::Operations::ResetPassword.new.call(
      token: "badtoken",
      password: "newpassword1",
      password_confirmation: "newpassword1"
    )
    failure!(result, :invalid_token)
  end

  test "fails when passwords do not match" do
    result = Auth::Operations::ResetPassword.new.call(
      token: @raw_token,
      password: "newpassword1",
      password_confirmation: "different1"
    )
    failure!(result, :validation_error)
  end

  test "fails when password is too short" do
    result = Auth::Operations::ResetPassword.new.call(
      token: @raw_token,
      password: "short",
      password_confirmation: "short"
    )
    failure!(result, :validation_error)
  end
end
