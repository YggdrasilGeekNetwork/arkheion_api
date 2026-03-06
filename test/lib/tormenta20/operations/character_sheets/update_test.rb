# frozen_string_literal: true

require_relative "../operation_test_case"

class CharacterSheetUpdateOperationTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    @user  = create_user
    @sheet = create_sheet_for(@user)
  end

  test "updates allowed fields" do
    result = Tormenta20::Operations::CharacterSheets::Update.new.call(
      id: @sheet.id,
      params: { name: "Renamed Hero", deity_key: "tanna-toh" },
      user: @user
    )

    value = success!(result)
    assert_equal "Renamed Hero", value[:character_sheet].name
    assert_equal "tanna-toh", value[:character_sheet].deity_key
  end

  test "persists the change to the database" do
    Tormenta20::Operations::CharacterSheets::Update.new.call(
      id: @sheet.id,
      params: { name: "DB Persisted" },
      user: @user
    )

    assert_equal "DB Persisted", @sheet.reload.name
  end

  test "returns not_found for a sheet that belongs to another user" do
    other = create_user
    result = Tormenta20::Operations::CharacterSheets::Update.new.call(
      id: @sheet.id,
      params: { name: "Hijack" },
      user: other
    )

    failure!(result, :not_found)
  end

  test "returns not_found for a non-existent id" do
    result = Tormenta20::Operations::CharacterSheets::Update.new.call(
      id: 0,
      params: { name: "Ghost" },
      user: @user
    )

    failure!(result, :not_found)
  end

  test "ignores fields not in the allowed list" do
    original_race = @sheet.race_key

    Tormenta20::Operations::CharacterSheets::Update.new.call(
      id: @sheet.id,
      params: { race_key: "elfo", name: "Still Me" },
      user: @user
    )

    assert_equal original_race, @sheet.reload.race_key
    assert_equal "Still Me", @sheet.reload.name
  end
end
