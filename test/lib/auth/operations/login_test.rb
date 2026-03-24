# frozen_string_literal: true

require_relative "auth_operation_test_case"

class Auth::Operations::LoginTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    @user = create_user(email: "login_test_#{SecureRandom.hex(4)}@example.com", password: "password123")
  end

  test "succeeds with valid credentials" do
    result = Auth::Operations::Login.new.call(email: @user.email, password: "password123")
    value = success!(result)
    assert value[:user]
    assert value[:tokens][:access_token]
    assert value[:tokens][:refresh_token]
  end

  test "fails with wrong password" do
    result = Auth::Operations::Login.new.call(email: @user.email, password: "wrongpass")
    payload = failure!(result, :invalid_credentials)
    assert_match(/Invalid email or password/, payload)
  end

  test "fails when user not found" do
    result = Auth::Operations::Login.new.call(email: "ghost@example.com", password: "password123")
    failure!(result, :invalid_credentials)
  end

  test "fails with no_password for oauth-only user" do
    oauth_user = User.create!(
      email: "oauth_#{SecureRandom.hex(4)}@example.com",
      username: "oauth_#{SecureRandom.hex(4)}",
      confirmed_at: Time.current
    )
    oauth_user.update_column(:encrypted_password, nil)
    OauthIdentity.create!(user: oauth_user, provider: "google", uid: SecureRandom.hex(8))

    result = Auth::Operations::Login.new.call(email: oauth_user.email, password: "anything")
    payload = failure!(result, :no_password)
    assert_match(/Google/, payload)
  end

  test "fails when account is inactive" do
    @user.update!(active: false)
    result = Auth::Operations::Login.new.call(email: @user.email, password: "password123")
    failure!(result, :account_disabled)
  end
end
