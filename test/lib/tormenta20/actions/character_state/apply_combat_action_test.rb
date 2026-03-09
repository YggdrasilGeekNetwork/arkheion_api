# frozen_string_literal: true

require_relative "../action_test_case"

class ApplyCombatActionActionTest < ActiveSupport::TestCase
  include ActionTestCase

  setup do
    @user = create_user
    @sheet = create_sheet_for(@user)
  end

  test "damage action reduces current_pv" do
    state_before = @sheet.character_state.current_pv

    result = Tormenta20::Actions::CharacterState::ApplyCombatAction.call(
      character_sheet: @sheet,
      input: { action_type: "damage", amount: 5 }
    )

    value = success!(result)
    assert value[:current_pv] < state_before || value[:current_pv] == 0
  end

  test "heal action restores current_pv" do
    # Damage first
    @sheet.character_state.update!(current_pv: 1)

    result = Tormenta20::Actions::CharacterState::ApplyCombatAction.call(
      character_sheet: @sheet,
      input: { action_type: "heal", amount: 10 }
    )

    value = success!(result)
    assert value[:current_pv] > 1
  end

  test "unknown action_type returns invalid_action failure" do
    result = Tormenta20::Actions::CharacterState::ApplyCombatAction.call(
      character_sheet: @sheet,
      input: { action_type: "cast_spell" }
    )

    failure!(result, :invalid_action)
  end
end
