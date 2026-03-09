# frozen_string_literal: true

require_relative "../action_test_case"

class CharacterStateManageActionTest < ActiveSupport::TestCase
  include ActionTestCase

  setup do
    @user = create_user
    @sheet = create_sheet_for(@user)
  end

  test "rest operation succeeds" do
    result = Tormenta20::Actions::CharacterState::Manage.call(
      character_sheet: @sheet,
      input: { operation: "rest", rest_type: "short" }
    )

    success!(result)
  end

  test "add_condition operation succeeds" do
    result = Tormenta20::Actions::CharacterState::Manage.call(
      character_sheet: @sheet,
      input: { operation: "add_condition", condition_key: "abalado" }
    )

    success!(result)
  end

  test "remove_condition operation succeeds after adding" do
    Tormenta20::Actions::CharacterState::Manage.call(
      character_sheet: @sheet,
      input: { operation: "add_condition", condition_key: "abalado" }
    )

    result = Tormenta20::Actions::CharacterState::Manage.call(
      character_sheet: @sheet,
      input: { operation: "remove_condition", condition_key: "abalado" }
    )

    success!(result)
  end

  test "unknown operation returns invalid_operation failure" do
    result = Tormenta20::Actions::CharacterState::Manage.call(
      character_sheet: @sheet,
      input: { operation: "teleport" }
    )

    failure!(result, :invalid_operation)
  end
end
