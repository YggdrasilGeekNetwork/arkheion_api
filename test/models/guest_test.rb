# frozen_string_literal: true

require "test_helper"

class GuestTest < ActiveSupport::TestCase
  test "valid guest" do
    guest = Guest.new(email: "test@example.com")
    assert guest.valid?
  end

  test "invalid without email" do
    guest = Guest.new
    assert_not guest.valid?
    assert_includes guest.errors[:email], "can't be blank"
  end

  test "invalid with duplicate email" do
    Guest.create!(email: "dup@example.com")
    guest = Guest.new(email: "dup@example.com")
    assert_not guest.valid?
    assert_includes guest.errors[:email], "has already been taken"
  end

  test "email is downcased on save" do
    guest = Guest.create!(email: "Upper@Example.COM")
    assert_equal "upper@example.com", guest.email
  end

  test "used? returns false when used_at is nil" do
    guest = Guest.new(email: "a@b.com")
    assert_not guest.used?
  end

  test "mark_as_used! sets used_at" do
    guest = Guest.create!(email: "mark@example.com")
    guest.mark_as_used!
    assert_not_nil guest.reload.used_at
    assert guest.used?
  end

  test "destroying guest also destroys associated user" do
    guest = Guest.create!(email: "linked@example.com")
    user = User.create!(
      email: "linked@example.com",
      username: "linkeduser",
      password: "password123",
      confirmed_at: Time.current,
      active: true
    )
    assert_difference "User.count", -1 do
      guest.destroy
    end
    assert_nil User.find_by(email: "linked@example.com")
  end

  test "destroying guest without associated user does not raise" do
    guest = Guest.create!(email: "nouserww@example.com")
    assert_nothing_raised { guest.destroy }
  end
end
