# frozen_string_literal: true

require_relative "../operation_test_case"

class SnapshotGenerateOperationTest < ActiveSupport::TestCase
  include OperationTestCase

  setup do
    @user  = create_user
    @sheet = create_sheet_for(@user)
  end

  test "generates a snapshot with computed attributes" do
    result = Tormenta20::Operations::Snapshots::Generate.new.call(
      character_sheet: @sheet, force: true
    )

    value = success!(result)
    snap = value[:snapshot]
    assert_not_nil snap.id
    assert snap.computed_attributes.present?
    assert snap.computed_defenses.present?
    assert snap.computed_combat.present?
    assert snap.computed_skills.present?
    assert snap.computed_resources.present?
  end

  test "snapshot reflects sheet attributes" do
    result = Tormenta20::Operations::Snapshots::Generate.new.call(
      character_sheet: @sheet, force: true
    )

    snap = success!(result)[:snapshot]
    forca_total = snap.computed_attributes.dig("forca", "total")
    assert_equal 15, forca_total  # from VALID_SHEET_ATTRS
  end

  test "returns cached snapshot when checksum matches" do
    Tormenta20::Operations::Snapshots::Generate.new.call(character_sheet: @sheet, force: true)
    count_before = @sheet.snapshots.count

    result = Tormenta20::Operations::Snapshots::Generate.new.call(character_sheet: @sheet)

    value = success!(result)
    assert value[:cached], "Expected cached: true"
    assert_equal count_before, @sheet.snapshots.count, "Should not create a new snapshot"
  end

  test "force regeneration creates a new snapshot version" do
    Tormenta20::Operations::Snapshots::Generate.new.call(character_sheet: @sheet, force: true)
    count_before = @sheet.snapshots.count

    result = Tormenta20::Operations::Snapshots::Generate.new.call(
      character_sheet: @sheet, force: true
    )

    success!(result)
    assert_equal count_before + 1, @sheet.snapshots.count
  end

  test "pv_max is positive after generation" do
    result = Tormenta20::Operations::Snapshots::Generate.new.call(
      character_sheet: @sheet, force: true
    )

    snap = success!(result)[:snapshot]
    assert snap.pv_max > 0
  end
end
