# frozen_string_literal: true

require_relative "../../unit_test_helper"

class RaceChoicesBuilderTest < ActiveSupport::TestCase
  FakeRaca = Struct.new(:id)

  # ── helpers ────────────────────────────────────────────────────────────────

  def build(race_id)
    Tormenta20::RaceChoicesBuilder.build(FakeRaca.new(race_id))
  end

  def find_choice(choices, id)
    choices.find { |c| c[:id] == id }
  end

  # ── unknown race ───────────────────────────────────────────────────────────

  test "returns empty array for races with no custom choices" do
    %w[elfo anao goblin dahllan aggelus hynne medusa minotauro trog sulfure].each do |id|
      assert_equal [], build(id), "expected no choices for #{id}"
    end
  end

  # ── osteon ─────────────────────────────────────────────────────────────────

  # ── sereia/tritão ───────────────────────────────────────────────────────────

  test "sereia_tritao has 2 choices" do
    assert_equal 2, build("sereia_tritao").length
  end

  test "sereia_tritao attr-bonus: 3 selections, all 6 attributes" do
    choice = find_choice(build("sereia_tritao"), "attr-bonus")
    assert_equal "attribute-bonus", choice[:effectType]
    assert_equal 3, choice[:minSelections]
    assert_equal 3, choice[:maxSelections]
    assert_equal 6, choice[:options].length
  end

  test "sereia_tritao cancao-dos-mares: spell-grant, 2 of 6 spells" do
    choice = find_choice(build("sereia_tritao"), "cancao-dos-mares")
    assert_equal "spell-grant", choice[:effectType]
    assert_equal 2, choice[:minSelections]
    assert_equal 2, choice[:maxSelections]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "amedrontar"
    assert_includes ids, "sono"
    assert_equal 6, ids.length
  end

  # ── sílfide ─────────────────────────────────────────────────────────────────

  test "silfide has 1 choice" do
    assert_equal 1, build("silfide").length
  end

  test "silfide magia-das-fadas: spell-grant, 2 of 4 spells" do
    choice = find_choice(build("silfide"), "magia-das-fadas")
    assert_equal "spell-grant", choice[:effectType]
    assert_equal 2, choice[:minSelections]
    assert_equal 2, choice[:maxSelections]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "criar_ilusao"
    assert_includes ids, "enfeiticar"
    assert_includes ids, "luz"
    assert_includes ids, "sono"
  end

  # ── kliren ──────────────────────────────────────────────────────────────────

  test "kliren has 1 choice" do
    assert_equal 1, build("kliren").length
  end

  test "kliren skill-training: options empty (injected by frontend)" do
    choice = find_choice(build("kliren"), "skill-training")
    assert_equal "skill-training", choice[:effectType]
    assert_equal 1, choice[:minSelections]
    assert_equal 1, choice[:maxSelections]
    assert_equal "race", choice[:targetStep]
    assert_equal [], choice[:options]
  end

  # ── golem ───────────────────────────────────────────────────────────────────

  test "golem has 2 choices" do
    assert_equal 2, build("golem").length
  end

  test "golem fonte-elemental: element-choice, 1 of 7 elements" do
    choice = find_choice(build("golem"), "fonte-elemental")
    assert_equal "element-choice", choice[:effectType]
    assert_equal 1, choice[:minSelections]
    assert_equal 1, choice[:maxSelections]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "fogo"
    assert_includes ids, "frio"
    assert_includes ids, "eletricidade"
    assert_equal 6, ids.length
  end

  test "golem proposito-de-criacao: general power, options from DB" do
    choice = find_choice(build("golem"), "proposito-de-criacao")
    assert_equal 1, choice[:minSelections]
    assert_equal 1, choice[:maxSelections]
    assert_equal "abilities", choice[:targetStep]
    assert choice[:options].length > 0
    assert choice[:options].all? { |o| o[:id].present? && o[:name].present? }
  end

  # ── qareen ──────────────────────────────────────────────────────────────────

  test "qareen has 2 choices" do
    assert_equal 2, build("qareen").length
  end

  test "qareen resistencia-elemental: element-choice, same elements as golem" do
    choice = find_choice(build("qareen"), "resistencia-elemental")
    assert_equal "element-choice", choice[:effectType]
    assert_equal 1, choice[:minSelections]
    assert_equal 1, choice[:maxSelections]
    assert_equal 6, choice[:options].length
  end

  test "qareen tatuagem-mistica: spell-grant, 1st circle spells from DB" do
    choice = find_choice(build("qareen"), "tatuagem-mistica")
    assert_equal "spell-grant", choice[:effectType]
    assert_equal 1, choice[:minSelections]
    assert_equal 1, choice[:maxSelections]
    assert choice[:options].length > 0
    assert choice[:options].all? { |o| o[:id].present? && o[:name].present? }
  end

  # ── osteon ─────────────────────────────────────────────────────────────────

  test "osteon has 2 choices" do
    assert_equal 2, build("osteon").length
  end

  test "osteon attr-bonus: 2 selections, excludes CON" do
    choice = find_choice(build("osteon"), "attr-bonus")
    assert_equal "attribute-bonus", choice[:effectType]
    assert_equal 2, choice[:minSelections]
    assert_equal 2, choice[:maxSelections]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "FOR"
    assert_includes ids, "DES"
    assert_includes ids, "INT"
    assert_includes ids, "SAB"
    assert_includes ids, "CAR"
    refute_includes ids, "CON"
    assert_equal 5, ids.length
  end

  test "osteon memoria-postuma-mode: effectType, single choice, three variants" do
    choice = find_choice(build("osteon"), "memoria-postuma-mode")
    assert_equal "memoria-postuma-mode", choice[:effectType]
    assert_equal "single", choice[:type]
    assert_equal "race", choice[:targetStep]
    assert_equal 1, choice[:minSelections]
    assert_equal 1, choice[:maxSelections]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "trained-skill"
    assert_includes ids, "general-power"
    assert_includes ids, "racial-ability-other-race"
    assert_equal 3, ids.length
  end

  # ── humano ─────────────────────────────────────────────────────────────────

  test "humano has 2 choices" do
    assert_equal 2, build("humano").length
  end

  test "humano attr-bonus: effectType, 3 selections, all 6 attributes" do
    choice = find_choice(build("humano"), "attr-bonus")
    assert_equal "attribute-bonus", choice[:effectType]
    assert_equal 3, choice[:minSelections]
    assert_equal 3, choice[:maxSelections]
    assert_equal "multiple", choice[:type]
    assert_equal "race", choice[:targetStep]
    ids = choice[:options].map { |o| o[:id] }
    assert_equal %w[FOR DES CON INT SAB CAR], ids
  end

  test "humano versatil-mode: effectType, single choice, two variants" do
    choice = find_choice(build("humano"), "versatil-mode")
    assert_equal "versatil-mode", choice[:effectType]
    assert_equal "single", choice[:type]
    assert_equal 1, choice[:minSelections]
    assert_equal 1, choice[:maxSelections]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "two-skills"
    assert_includes ids, "skill-and-power"
    assert_equal 2, ids.length
  end

  # ── lefou ──────────────────────────────────────────────────────────────────

  test "lefou has 2 choices" do
    assert_equal 2, build("lefou").length
  end

  test "lefou attr-bonus: 2 selections, excludes CAR" do
    choice = find_choice(build("lefou"), "attr-bonus")
    assert_equal "attribute-bonus", choice[:effectType]
    assert_equal 2, choice[:minSelections]
    assert_equal 2, choice[:maxSelections]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "FOR"
    assert_includes ids, "DES"
    assert_includes ids, "CON"
    assert_includes ids, "INT"
    assert_includes ids, "SAB"
    refute_includes ids, "CAR"
    assert_equal 5, ids.length
  end

  test "lefou deformidade-mode: effectType, single choice, two variants" do
    choice = find_choice(build("lefou"), "deformidade-mode")
    assert_equal "deformidade-mode", choice[:effectType]
    assert_equal "single", choice[:type]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "two-skill-bonuses"
    assert_includes ids, "skill-and-tormenta"
    assert_equal 2, ids.length
  end
end
