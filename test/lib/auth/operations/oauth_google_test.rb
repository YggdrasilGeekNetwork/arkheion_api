# frozen_string_literal: true

require_relative "auth_operation_test_case"

class Auth::Operations::OauthGoogleTest < ActiveSupport::TestCase
  include OperationTestCase

  FAKE_PAYLOAD = {
    "sub"     => "google_uid_123",
    "email"   => "google_#{SecureRandom.hex(4)}@gmail.com",
    "name"    => "Google User",
    "picture" => "https://example.com/avatar.jpg"
  }.freeze

  setup do
    @payload = FAKE_PAYLOAD.merge("email" => "google_#{SecureRandom.hex(4)}@gmail.com",
                                  "sub"   => SecureRandom.hex(8))
  end

  def call_with_stub(payload = @payload)
    Auth::GoogleTokenVerifier.stub(:verify!, payload) do
      Auth::Operations::OauthGoogle.new.call(id_token: "fake_token")
    end
  end

  test "creates new user and identity on first login" do
    result = call_with_stub
    value = success!(result)
    assert value[:user]
    assert value[:tokens][:access_token]
    assert OauthIdentity.exists?(provider: "google", uid: @payload["sub"])
    assert User.exists?(email: @payload["email"])
  end

  test "returns existing user when identity already exists" do
    call_with_stub # create first
    result = call_with_stub # login again
    value = success!(result)
    assert_equal 1, OauthIdentity.where(provider: "google", uid: @payload["sub"]).count
    assert value[:user]
  end

  test "links google to existing email account" do
    existing = create_user(email: @payload["email"], password: "password123")
    result = call_with_stub
    value = success!(result)
    assert_equal existing.id, value[:user].id
    assert OauthIdentity.exists?(user: existing, provider: "google")
    existing.reload
    assert existing.confirmed?
  end

  test "fails when google token is invalid" do
    Auth::GoogleTokenVerifier.stub(:verify!, ->(_t) { raise Auth::GoogleTokenError, "bad token" }) do
      result = Auth::Operations::OauthGoogle.new.call(id_token: "bad")
      failure!(result, :invalid_token)
    end
  end
end
