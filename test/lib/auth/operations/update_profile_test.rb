# frozen_string_literal: true

require_relative "auth_operation_test_case"

class Auth::Operations::UpdateProfileTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    @user = create_user(email: "profile_#{SecureRandom.hex(4)}@example.com", password: "password123")
  end

  test "updates username" do
    new_username = "newuser_#{SecureRandom.hex(4)}"
    result = Auth::Operations::UpdateProfile.new.call(user: @user, username: new_username)
    value = success!(result)
    assert_equal new_username, value[:user].username
  end

  test "updates display_name" do
    result = Auth::Operations::UpdateProfile.new.call(user: @user, display_name: "New Name")
    value = success!(result)
    assert_equal "New Name", value[:user].display_name
  end

  test "clears display_name when passed empty string" do
    @user.update!(display_name: "Old Name")
    result = Auth::Operations::UpdateProfile.new.call(user: @user, display_name: "")
    value = success!(result)
    assert_equal "", value[:user].display_name
  end

  test "succeeds when no attributes provided" do
    result = Auth::Operations::UpdateProfile.new.call(user: @user)
    value = success!(result)
    assert value[:user]
  end

  test "fails with duplicate username" do
    other = create_user(email: "other_#{SecureRandom.hex(4)}@example.com", password: "password123")
    result = Auth::Operations::UpdateProfile.new.call(user: @user, username: other.username)
    failure!(result, :validation_error)
  end

  test "fails with username too short" do
    result = Auth::Operations::UpdateProfile.new.call(user: @user, username: "ab")
    failure!(result, :validation_error)
  end
end
