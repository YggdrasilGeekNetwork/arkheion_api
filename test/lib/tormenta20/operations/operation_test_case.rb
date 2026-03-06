# frozen_string_literal: true

require "test_helper"

# Shared helpers for operation integration tests.
# These tests require the database (PostgreSQL).
#
# Dry::Operation wraps return values differently depending on the exit path:
#   - Success via call  → Success(Success({...}))  outer=Success, inner=Success
#   - Failure via step  → Failure([...])            proper Failure
#   - Failure via early return (return Failure[...]) → Success(Failure([...]))
#
# `unwrap_result` normalises all three to a single inner monad.
module OperationTestCase
  VALID_SHEET_ATTRS = {
    "forca" => 15, "destreza" => 14, "constituicao" => 13,
    "inteligencia" => 12, "sabedoria" => 11, "carisma" => 10
  }.freeze

  # Valid params for CharacterSheets::Create (contract-validated)
  def valid_sheet_params(overrides = {})
    {
      name: "Test Character",
      race_key: "humano",
      origin_key: "acolito",
      sheet_attributes: VALID_SHEET_ATTRS
    }.merge(overrides)
  end

  # Valid params for LevelUps::Create / first_level in Characters::Create
  def valid_first_level_params(overrides = {})
    {
      class_key: "guerreiro",
      abilities_chosen: {},
      powers_chosen: {},
      skill_points: {}
    }.merge(overrides)
  end

  # Valid params for Characters::Create (gem-reference-validated)
  def valid_character_params(overrides = {})
    {
      name: "Test Character",
      race_key: "humano",
      origin_key: "acolito",
      sheet_attributes: VALID_SHEET_ATTRS,
      first_level: valid_first_level_params
    }.merge(overrides)
  end

  def create_user(email: "op_test_#{SecureRandom.hex(4)}@example.com", username: nil, password: "password123")
    username ||= "user_#{SecureRandom.hex(4)}"
    User.create!(email: email, username: username, password: password)
  end

  def create_sheet_for(user, overrides = {})
    result = Tormenta20::Operations::CharacterSheets::Create.new.call(
      params: valid_sheet_params(overrides),
      first_level_params: valid_first_level_params,
      user: user
    )
    monad = unwrap_result(result)
    assert monad.success?, "Sheet creation failed: #{monad.failure.inspect}"
    monad.value![:character_sheet]
  end

  # Returns the inner monad (Success or Failure) after stripping Dry::Operation's outer wrapper.
  def unwrap_result(result)
    result.success? ? result.value! : result
  end

  def success!(result, msg = nil)
    monad = unwrap_result(result)
    assert monad.success?, msg || "Expected Success but got Failure: #{monad.failure.inspect}"
    monad.value!
  end

  def failure!(result, expected_type = nil)
    monad = unwrap_result(result)
    assert monad.failure?, "Expected Failure but got Success: #{monad.success? ? monad.value!.inspect : 'unknown'}"
    type, payload = monad.failure
    assert_equal expected_type, type if expected_type
    payload
  end
end
