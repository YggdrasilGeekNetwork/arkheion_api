# frozen_string_literal: true

require_relative "../action_test_case"

class CharacterCreateActionTest < ActiveSupport::TestCase
  include ActionTestCase

  setup do
    @user = create_user
  end

  test "delegates to Characters::Create operation and returns character presenter" do
    result = Tormenta20::Actions::Characters::Create.call(
      params: valid_character_params,
      user: @user
    )

    value = success!(result)
    assert_not_nil value[:character]
    assert_equal "Test Character", value[:character].name
  end

  test "returns validation failure for invalid race_key" do
    result = Tormenta20::Actions::Characters::Create.call(
      params: valid_character_params(race_key: "invalido"),
      user: @user
    )

    errors = failure!(result, :validation_error)
    assert errors.key?(:race_key)
  end

  test "associates created character with the given user" do
    Tormenta20::Actions::Characters::Create.call(
      params: valid_character_params,
      user: @user
    )

    assert Tormenta20::CharacterSheet.where(user: @user).exists?
  end
end
