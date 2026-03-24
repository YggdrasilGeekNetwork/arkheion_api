# frozen_string_literal: true

require_relative "auth_operation_test_case"

class Auth::Operations::SetPasswordTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    # OAuth-only user (no encrypted_password)
    @user = User.create!(
      email: "setpw_#{SecureRandom.hex(4)}@example.com",
      username: "setpw_#{SecureRandom.hex(4)}",
      confirmed_at: Time.current
    )
    @user.update_column(:encrypted_password, nil)
    OauthIdentity.create!(user: @user, provider: "google", uid: SecureRandom.hex(8))
  end

  test "sets password for oauth-only user" do
    result = Auth::Operations::SetPassword.new.call(
      user: @user,
      password: "newpass123",
      password_confirmation: "newpass123"
    )
    value = success!(result)
    assert value[:user]
    assert value[:tokens][:access_token]
    @user.reload
    assert @user.valid_password?("newpass123")
  end

  test "fails when passwords do not match" do
    result = Auth::Operations::SetPassword.new.call(
      user: @user,
      password: "newpass123",
      password_confirmation: "different"
    )
    failure!(result, :validation_error)
  end

  test "fails when password is too short" do
    result = Auth::Operations::SetPassword.new.call(
      user: @user,
      password: "short",
      password_confirmation: "short"
    )
    failure!(result, :validation_error)
  end
end
