# frozen_string_literal: true

require_relative "../operation_test_case"

class CharacterSheetCreateOperationTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    @user = create_user
  end

  test "creates a character sheet with valid params" do
    result = Tormenta20::Operations::CharacterSheets::Create.new.call(
      params: valid_sheet_params,
      first_level_params: valid_first_level_params,
      user: @user
    )

    value = success!(result)
    assert_not_nil value[:character_sheet].id
    assert_equal "Test Character", value[:character_sheet].name
    assert_equal "humano", value[:character_sheet].race_key
  end

  test "creates an associated level_up" do
    result = Tormenta20::Operations::CharacterSheets::Create.new.call(
      params: valid_sheet_params,
      first_level_params: valid_first_level_params,
      user: @user
    )

    sheet = success!(result)[:character_sheet]
    assert_equal 1, sheet.level_ups.count
    assert_equal 1, sheet.level_ups.first.level
    assert_equal "guerreiro", sheet.level_ups.first.class_key
  end

  test "creates an initial snapshot" do
    result = Tormenta20::Operations::CharacterSheets::Create.new.call(
      params: valid_sheet_params,
      first_level_params: valid_first_level_params,
      user: @user
    )

    sheet = success!(result)[:character_sheet]
    assert sheet.snapshots.exists?
  end

  test "initializes character state with computed PV/PM" do
    result = Tormenta20::Operations::CharacterSheets::Create.new.call(
      params: valid_sheet_params,
      first_level_params: valid_first_level_params,
      user: @user
    )

    sheet = success!(result)[:character_sheet]
    state = sheet.character_state
    assert_not_nil state
    assert state.current_pv > 0, "Expected current_pv to be set from snapshot"
    assert state.current_pm >= 0
  end

  test "fails with missing required params" do
    result = Tormenta20::Operations::CharacterSheets::Create.new.call(
      params: { name: "", race_key: "humano", origin_key: "acolito",
                sheet_attributes: VALID_SHEET_ATTRS },
      first_level_params: nil,
      user: @user
    )

    failure!(result, :validation_error)
  end

  test "fails when sheet_attributes sum is out of range" do
    bad_attrs = { "forca" => 8, "destreza" => 8, "constituicao" => 8,
                  "inteligencia" => 8, "sabedoria" => 8, "carisma" => 8 }
    result = Tormenta20::Operations::CharacterSheets::Create.new.call(
      params: valid_sheet_params(sheet_attributes: bad_attrs),
      first_level_params: nil,
      user: @user
    )

    failure!(result, :validation_error)
  end

  test "associates sheet with the given user" do
    result = Tormenta20::Operations::CharacterSheets::Create.new.call(
      params: valid_sheet_params,
      first_level_params: valid_first_level_params,
      user: @user
    )

    sheet = success!(result)[:character_sheet]
    assert_equal @user.id, sheet.user_id
  end
end
