# frozen_string_literal: true

require_relative "auth_operation_test_case"

class Auth::Operations::ForgotPasswordTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    @user = create_user(email: "forgot_#{SecureRandom.hex(4)}@example.com", password: "password123")
    ActionMailer::Base.deliveries.clear
  end

  test "returns success even when email not found" do
    result = Auth::Operations::ForgotPassword.new.call(email: "nobody@example.com")
    value = success!(result)
    assert_equal true, value
    assert_empty ActionMailer::Base.deliveries
  end

  test "queues reset email when user exists" do
    # deliver_later with test adapter records in deliveries
    result = Auth::Operations::ForgotPassword.new.call(email: @user.email)
    value = success!(result)
    assert_equal true, value
    @user.reload
    assert @user.reset_password_token.present?
    assert @user.reset_password_sent_at.present?
  end
end
