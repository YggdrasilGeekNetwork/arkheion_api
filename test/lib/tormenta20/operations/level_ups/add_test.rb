# frozen_string_literal: true

require_relative "../operation_test_case"

class LevelUpAddOperationTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    @user  = create_user
    @sheet = create_sheet_for(@user)  # already has level 1
  end

  test "adds a level and increments current_level" do
    result = Tormenta20::Operations::LevelUps::Add.new.call(
      character_sheet_id: @sheet.id,
      params: { class_key: "guerreiro" },
      user: @user
    )

    value = success!(result)
    assert_equal 2, value[:character_sheet].current_level
    assert_not_nil value[:level_up]
  end

  test "regenerates snapshot after leveling up" do
    snapshots_before = @sheet.snapshots.count

    Tormenta20::Operations::LevelUps::Add.new.call(
      character_sheet_id: @sheet.id,
      params: { class_key: "guerreiro" },
      user: @user
    )

    assert @sheet.reload.snapshots.count > snapshots_before
  end

  test "updates current_pv and current_pm after level up" do
    state_before_pv = @sheet.character_state.current_pv
    state_before_pm = @sheet.character_state.current_pm

    Tormenta20::Operations::LevelUps::Add.new.call(
      character_sheet_id: @sheet.id,
      params: { class_key: "guerreiro" },
      user: @user
    )

    state = @sheet.character_state.reload
    assert state.current_pv >= state_before_pv
    assert state.current_pm >= state_before_pm
  end

  test "fails when sheet does not belong to user" do
    other_user = create_user
    result = Tormenta20::Operations::LevelUps::Add.new.call(
      character_sheet_id: @sheet.id,
      params: { class_key: "guerreiro" },
      user: other_user
    )

    failure!(result)
  end

  test "fails when character is already at max level" do
    19.times do |i|
      Tormenta20::Operations::LevelUps::Add.new.call(
        character_sheet_id: @sheet.id,
        params: { class_key: "guerreiro" },
        user: @user
      )
    end

    result = Tormenta20::Operations::LevelUps::Add.new.call(
      character_sheet_id: @sheet.id,
      params: { class_key: "guerreiro" },
      user: @user
    )

    failure!(result, :max_level)
  end
end
