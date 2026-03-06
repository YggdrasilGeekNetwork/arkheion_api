# frozen_string_literal: true

require "test_helper"

# Shared helpers for operation integration tests.
# These tests require the database (PostgreSQL).
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
    assert result.success?, "Sheet creation failed: #{result.failure.inspect}"
    result.value![:character_sheet]
  end

  def success!(result, msg = nil)
    assert result.success?, msg || "Expected Success but got Failure: #{result.failure.inspect}"
    result.value!
  end

  def failure!(result, expected_type = nil)
    assert result.failure?, "Expected Failure but got Success"
    type, payload = result.failure
    assert_equal expected_type, type if expected_type
    payload
  end
end
