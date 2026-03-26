# frozen_string_literal: true

require_relative "../operation_test_case"

class CharacterCreateOperationTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    @user = create_user
  end

  test "creates a character and returns a presenter" do
    result = Tormenta20::Operations::Characters::Create.new.call(
      params: valid_character_params,
      user: @user
    )

    value = success!(result)
    assert_not_nil value[:character]
    assert_respond_to value[:character], :name
    assert_equal "Test Character", value[:character].name
  end

  test "creates sheet, level_up, snapshot, and state in one call" do
    result = Tormenta20::Operations::Characters::Create.new.call(
      params: valid_character_params,
      user: @user
    )

    success!(result)
    sheet = Tormenta20::CharacterSheet.last
    assert_equal 1, sheet.level_ups.count
    assert sheet.snapshots.exists?
    assert_not_nil sheet.character_state
  end

  test "initializes PV and PM from the computed snapshot" do
    result = Tormenta20::Operations::Characters::Create.new.call(
      params: valid_character_params,
      user: @user
    )

    success!(result)
    state = Tormenta20::CharacterSheet.last.character_state
    assert state.current_pv > 0
    assert state.current_pm >= 0
  end

  test "fails with an invalid race_key" do
    result = Tormenta20::Operations::Characters::Create.new.call(
      params: valid_character_params(race_key: "nao_existe"),
      user: @user
    )

    errors = failure!(result, :validation_error)
    assert errors.key?(:race_key)
  end

  test "fails with an invalid origin_key" do
    result = Tormenta20::Operations::Characters::Create.new.call(
      params: valid_character_params(origin_key: "nao_existe"),
      user: @user
    )

    errors = failure!(result, :validation_error)
    assert errors.key?(:origin_key)
  end

  test "fails with an invalid class_key in first_level" do
    result = Tormenta20::Operations::Characters::Create.new.call(
      params: valid_character_params(first_level: { class_key: "nao_existe" }),
      user: @user
    )

    errors = failure!(result, :validation_error)
    assert errors.key?(:class_key)
  end

  test "associates the character with the user" do
    Tormenta20::Operations::Characters::Create.new.call(
      params: valid_character_params,
      user: @user
    )

    assert Tormenta20::CharacterSheet.where(user: @user).exists?
  end

  test "initializes inventory and currency from starting params" do
    params = valid_character_params(
      starting_inventory: [
        { item_key: "espada_longa", item_id: "start-espada_longa", quantity: 1 },
        { item_key: "armadura_de_couro", item_id: "start-armadura_de_couro", quantity: 1 }
      ],
      starting_currency: { tc: 0, tp: 0, to: 12 }
    )

    result = Tormenta20::Operations::Characters::Create.new.call(params: params, user: @user)
    success!(result)

    state = Tormenta20::CharacterSheet.last.character_state
    assert_equal 2, state.inventory.length
    assert_equal "espada_longa", state.inventory.first["item_key"]
    assert_equal 12, state.currency["to"]
  end

  test "does not persist any record when validation fails" do
    count_before = Tormenta20::CharacterSheet.count

    Tormenta20::Operations::Characters::Create.new.call(
      params: valid_character_params(race_key: "nao_existe"),
      user: @user
    )

    assert_equal count_before, Tormenta20::CharacterSheet.count
  end
end
