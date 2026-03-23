# frozen_string_literal: true

require_relative "../../unit_test_helper"

class OriginChoicesBuilderTest < ActiveSupport::TestCase
  def build(origem_id)
    origem = Tormenta20::Models::Origem.find_by(id: origem_id)
    Tormenta20::OriginChoicesBuilder.build(origem)
  end

  def find_choice(choices, id)
    choices.find { |c| c[:id] == id }
  end

  # ── no benefits ─────────────────────────────────────────────────────────────

  test "returns empty array for origins with no benefits" do
    assert_equal [], build("amnesico")
  end

  # ── acolito (3 skills, 3 powers) ────────────────────────────────────────────

  test "acolito has 1 choice" do
    assert_equal 1, build("acolito").length
  end

  test "acolito origem-mode: single, all 3 options present" do
    choice = find_choice(build("acolito"), "origem-mode")
    assert_equal "origem-mode", choice[:effectType]
    assert_equal "single", choice[:type]
    assert_equal "origin", choice[:targetStep]
    assert_equal 1, choice[:minSelections]
    assert_equal 1, choice[:maxSelections]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "two-skills"
    assert_includes ids, "two-powers"
    assert_includes ids, "skill-and-power"
  end

  test "acolito origem-mode: embeds available skills and powers" do
    choice = find_choice(build("acolito"), "origem-mode")
    assert choice[:availableSkills].length >= 2
    assert choice[:availableSkills].all? { |s| s[:id].present? && s[:name].present? }
    assert choice[:availablePowers].length >= 2
    assert choice[:availablePowers].all? { |p| p[:id].present? && p[:name].present? }
  end

  test "acolito powers include prerequisites key" do
    choice = find_choice(build("acolito"), "origem-mode")
    choice[:availablePowers].each do |p|
      assert p.key?(:prerequisites), "Power #{p[:name]} missing :prerequisites key"
      assert p[:prerequisites].is_a?(Array), "Power #{p[:name]} prerequisites should be an Array"
    end
  end

  # ── amigo_dos_animais (2 skills, 1 power — no two-powers option) ─────────────

  test "amigo_dos_animais has skill-and-power but not two-powers" do
    choice = find_choice(build("amigo_dos_animais"), "origem-mode")
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "two-skills"
    assert_includes ids, "skill-and-power"
    refute_includes ids, "two-powers"
  end
end
