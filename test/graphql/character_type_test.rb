# frozen_string_literal: true

require "test_helper"
require_relative "../lib/tormenta20/operations/operation_test_case"

class CharacterTypeTest < ActiveSupport::TestCase
  include OperationTestCase

  QUERY = <<~GQL
    query($id: ID!) {
      character(id: $id) {
        defenses { name value tooltip }
        spellSaveDc
        spellcastingAttribute
        spellDcTooltip
        attributes { label modifier }
      }
    }
  GQL

  setup do
    @user    = create_user
    @warrior = create_character(user: @user, class_key: "guerreiro")
    @mage    = create_character(user: @user, class_key: "arcanista",
                                sheet_attributes: {
                                  "forca" => 8, "destreza" => 14, "constituicao" => 12,
                                  "inteligencia" => 18, "sabedoria" => 14, "carisma" => 10
                                })
  end

  # ─── defenses ─────────────────────────────────────────────────────────────

  test "defenses always returns exactly one entry" do
    result = execute(@warrior.id)
    defenses = result.dig("data", "character", "defenses")
    assert_equal 1, defenses.length
    assert_equal "Defesa", defenses[0]["name"]
  end

  test "defenses value is at least 10" do
    result = execute(@warrior.id)
    value = result.dig("data", "character", "defenses", 0, "value")
    assert value >= 10
  end

  # ─── spell_save_dc / spellcasting_attribute ───────────────────────────────

  test "spellSaveDc and spellcastingAttribute are nil for non-caster" do
    result = execute(@warrior.id)
    assert_nil result.dig("data", "character", "spellSaveDc")
    assert_nil result.dig("data", "character", "spellcastingAttribute")
  end

  test "spellcastingAttribute is inteligencia for arcanista" do
    result = execute(@mage.id)
    assert_equal "inteligencia", result.dig("data", "character", "spellcastingAttribute")
  end

  test "spellSaveDc equals 10 plus inteligencia modifier for arcanista" do
    result = execute(@mage.id)
    # INT 18 → modifier +4 → DC = 10 + 4 = 14
    assert_equal 14, result.dig("data", "character", "spellSaveDc")
  end

  test "attributes are returned in canonical order" do
    result = execute(@warrior.id)
    labels = result.dig("data", "character", "attributes").map { |a| a["label"] }
    assert_equal %w[FOR DES CON SAB INT CAR], labels
  end

  test "spellDcTooltip is nil for non-caster" do
    result = execute(@warrior.id)
    assert_nil result.dig("data", "character", "spellDcTooltip")
  end

  test "spellDcTooltip includes base and attribute modifier for arcanista" do
    result = execute(@mage.id)
    tooltip = result.dig("data", "character", "spellDcTooltip")
    assert_includes tooltip, "10 (base)"
    assert_includes tooltip, "+4 (Inteligência)"
  end

  private

  def execute(sheet_id)
    ArkheionSchema.execute(QUERY, variables: { id: sheet_id }, context: { current_user: @user })
  end

  def create_character(user:, class_key:, sheet_attributes: nil)
    params = valid_character_params(
      first_level: valid_first_level_params(class_key: class_key)
    )
    params[:sheet_attributes] = sheet_attributes if sheet_attributes

    result = Tormenta20::Operations::Characters::Create.new.call(params: params, user: user)
    inner  = result.success? ? result.value! : result
    assert inner.success?, "Character creation failed: #{inner.failure.inspect}"
    inner.value![:character].sheet
  end
end
