# frozen_string_literal: true

require_relative "../operation_test_case"

class LevelUpCreateOperationTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    @user  = create_user
    @sheet = create_sheet_for(@user)  # already has level 1
  end

  test "creates a level_up with valid params" do
    result = Tormenta20::Operations::LevelUps::Create.new.call(
      character_sheet: @sheet,
      params: { class_key: "guerreiro", level: 2 }
    )

    value = success!(result)
    assert_not_nil value[:level_up].id
    assert_equal 2, value[:level_up].level
    assert_equal "guerreiro", value[:level_up].class_key
  end

  test "persists default empty hashes for optional fields" do
    result = Tormenta20::Operations::LevelUps::Create.new.call(
      character_sheet: @sheet,
      params: { class_key: "barbaro", level: 2 }
    )

    lu = success!(result)[:level_up]
    assert_equal({}, lu.abilities_chosen)
    assert_equal({}, lu.powers_chosen)
    assert_equal({}, lu.skill_points)
  end

  test "fails when level is missing" do
    result = Tormenta20::Operations::LevelUps::Create.new.call(
      character_sheet: @sheet,
      params: { class_key: "guerreiro" }
    )

    failure!(result, :validation_error)
  end

  test "fails when class_key is missing" do
    result = Tormenta20::Operations::LevelUps::Create.new.call(
      character_sheet: @sheet,
      params: { level: 2 }
    )

    failure!(result, :validation_error)
  end

  test "fails with duplicate level" do
    result = Tormenta20::Operations::LevelUps::Create.new.call(
      character_sheet: @sheet,
      params: { class_key: "guerreiro", level: 1 }  # level 1 already exists
    )

    assert result.failure?
  end
end
