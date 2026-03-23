# frozen_string_literal: true

require_relative "../../unit_test_helper"

class ClassChoicesBuilderTest < ActiveSupport::TestCase
  FakeClasse = Struct.new(:id)

  # ── helpers ─────────────────────────────────────────────────────────────────

  def build(class_id)
    Tormenta20::ClassChoicesBuilder.build(FakeClasse.new(class_id))
  end

  def find_choice(choices, id)
    choices.find { |c| c[:id] == id }
  end

  # ── classes with no choices ──────────────────────────────────────────────────

  test "returns empty array for classes with no custom choices" do
    %w[guerreiro barbaro ladino paladino ranger cacador
       cavaleiro bucaneiro nobre inventor lutador].each do |id|
      assert_equal [], build(id), "expected no choices for #{id}"
    end
  end

  # ── arcanista ────────────────────────────────────────────────────────────────

  test "arcanista has 8 choices" do
    assert_equal 8, build("arcanista").length
  end

  test "arcanista caminho-do-arcanista: single, 3 path options" do
    choice = find_choice(build("arcanista"), "caminho-do-arcanista")
    assert_equal "caminho-do-arcanista", choice[:effectType]
    assert_equal "single", choice[:type]
    assert_equal "class", choice[:targetStep]
    assert_equal 1, choice[:minSelections]
    assert_equal 1, choice[:maxSelections]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "bruxo"
    assert_includes ids, "feiticeiro"
    assert_includes ids, "mago"
    assert_equal 3, ids.length
  end

  test "arcanista linhagem-do-feiticeiro: single, 3 linhagens, dependsOn feiticeiro" do
    choice = find_choice(build("arcanista"), "linhagem-do-feiticeiro")
    assert_equal "linhagem-do-feiticeiro", choice[:effectType]
    assert_equal "single", choice[:type]
    assert_equal "class", choice[:targetStep]
    assert_equal 1, choice[:minSelections]
    assert_equal 1, choice[:maxSelections]
    assert_equal "feiticeiro", choice[:dependsOn]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "draconico"
    assert_includes ids, "feerica"
    assert_includes ids, "rubra"
    assert_equal 3, ids.length
  end

  test "arcanista linhagem-draconico-elemento: element-choice, 4 elements, dependsOn draconico" do
    choice = find_choice(build("arcanista"), "linhagem-draconico-elemento")
    assert_equal "element-choice", choice[:effectType]
    assert_equal "single", choice[:type]
    assert_equal "draconico", choice[:dependsOn]
    ids = choice[:options].map { |o| o[:id] }
    assert_includes ids, "acido"
    assert_includes ids, "eletricidade"
    assert_includes ids, "fogo"
    assert_includes ids, "frio"
    assert_equal 4, ids.length
  end

  test "arcanista linhagem-feerica-magia: spell-grant, enchantment/illusion spells, dependsOn feerica" do
    choice = find_choice(build("arcanista"), "linhagem-feerica-magia")
    assert_equal "spell-grant", choice[:effectType]
    assert_equal "single", choice[:type]
    assert_equal "feerica", choice[:dependsOn]
    assert choice[:options].length > 0
    assert choice[:options].all? { |o| o[:id].present? && o[:name].present? }
  end

  test "arcanista linhagem-rubra-poder: Tormenta powers, dependsOn rubra" do
    choice = find_choice(build("arcanista"), "linhagem-rubra-poder")
    assert_equal "rubra", choice[:dependsOn]
    assert choice[:options].length > 0
    assert choice[:options].all? { |o| o[:id].present? && o[:name].present? }
  end

  test "arcanista magias-iniciais-bruxo: spell-grant, exactly 3 spells, dependsOn bruxo" do
    choice = find_choice(build("arcanista"), "magias-iniciais-bruxo")
    assert_equal "spell-grant", choice[:effectType]
    assert_equal "multiple", choice[:type]
    assert_equal "class", choice[:targetStep]
    assert_equal 3, choice[:minSelections]
    assert_equal 3, choice[:maxSelections]
    assert_equal "bruxo", choice[:dependsOn]
    assert choice[:options].length > 0
    assert choice[:options].all? { |o| o[:id].present? && o[:name].present? }
  end

  test "arcanista magias-iniciais-feiticeiro: spell-grant, exactly 3 spells, dependsOn feiticeiro" do
    choice = find_choice(build("arcanista"), "magias-iniciais-feiticeiro")
    assert_equal 3, choice[:minSelections]
    assert_equal 3, choice[:maxSelections]
    assert_equal "feiticeiro", choice[:dependsOn]
  end

  test "arcanista magias-iniciais-mago: spell-grant, exactly 4 spells, dependsOn mago" do
    choice = find_choice(build("arcanista"), "magias-iniciais-mago")
    assert_equal 4, choice[:minSelections]
    assert_equal 4, choice[:maxSelections]
    assert_equal "mago", choice[:dependsOn]
  end

  # ── bardo ────────────────────────────────────────────────────────────────────

  test "bardo has escola-de-magias + per-school spell choices" do
    choices = build("bardo")
    assert find_choice(choices, "escola-de-magias"), "expected escola-de-magias choice"
    # At least one per-school spell choice should exist
    school_choices = choices.select { |c| c[:id].start_with?("magias-iniciais-") }
    assert school_choices.length > 0
  end

  test "bardo escola-de-magias: multiple (3), escola-de-magias effectType, 8 school options" do
    choice = find_choice(build("bardo"), "escola-de-magias")
    assert_equal "escola-de-magias", choice[:effectType]
    assert_equal "multiple", choice[:type]
    assert_equal "class", choice[:targetStep]
    assert_equal 3, choice[:minSelections]
    assert_equal 3, choice[:maxSelections]
    assert_equal 8, choice[:options].length
    assert choice[:options].all? { |o| o[:id].present? && o[:name].present? }
  end

  test "bardo per-school choices: spell-grant, 3 spells, dependsOn school_id, arcana+universal" do
    choices = build("bardo")
    school_choices = choices.select { |c| c[:id].start_with?("magias-iniciais-") }
    school_choices.each do |sc|
      assert_equal "spell-grant", sc[:effectType]
      assert_equal "multiple", sc[:type]
      assert_equal 3, sc[:minSelections]
      assert_equal 3, sc[:maxSelections]
      assert sc[:dependsOn].present?, "expected dependsOn for #{sc[:id]}"
      assert sc[:options].length > 0
      # Each spell option must carry school metadata
      sc[:options].each do |opt|
        assert opt[:school].present?, "expected school code on spell #{opt[:id]}"
        assert opt[:schoolName].present?, "expected schoolName on spell #{opt[:id]}"
      end
    end
  end

  # ── clerigo ───────────────────────────────────────────────────────────────────

  test "clerigo has 1 choice" do
    assert_equal 1, build("clerigo").length
  end

  test "clerigo magias-iniciais: spell-grant, 3 divina+universal circle-1 spells" do
    choice = find_choice(build("clerigo"), "magias-iniciais")
    assert_equal "spell-grant", choice[:effectType]
    assert_equal "multiple", choice[:type]
    assert_equal "class", choice[:targetStep]
    assert_equal 3, choice[:minSelections]
    assert_equal 3, choice[:maxSelections]
    assert choice[:options].length > 0
    assert choice[:options].all? { |o| o[:id].present? && o[:name].present? }
    # No dependsOn — direct selection
    assert_nil choice[:dependsOn]
  end

  test "clerigo magias-iniciais options are divina or universal (not arcana)" do
    choice = find_choice(build("clerigo"), "magias-iniciais")
    ids = choice[:options].map { |o| o[:id] }
    db_types = ::Tormenta20::Models::Magia.where(id: ids).pluck(:type).uniq
    assert_empty(db_types - %w[divina universal])
    assert_not_includes db_types, "arcana"
  end

  # ── druida ───────────────────────────────────────────────────────────────────

  test "druida has escola-de-magias + per-school spell choices" do
    choices = build("druida")
    assert find_choice(choices, "escola-de-magias"), "expected escola-de-magias choice"
    school_choices = choices.select { |c| c[:id].start_with?("magias-iniciais-") }
    assert school_choices.length > 0
  end

  test "druida escola-de-magias: multiple (3), only schools with divina circle-1 spells" do
    choice = find_choice(build("druida"), "escola-de-magias")
    assert_equal "escola-de-magias", choice[:effectType]
    assert_equal "multiple", choice[:type]
    assert_equal 3, choice[:minSelections]
    assert_equal 3, choice[:maxSelections]
    # Schools are gated on primary type only — universal alone must not qualify a school
    choice[:options].each do |opt|
      count = ::Tormenta20::Models::Magia.where(circle: 1, school: opt[:id], type: "divina").count
      assert count > 0, "school #{opt[:id]} has no divina circle-1 spells (must qualify on primary type)"
    end
  end

  test "druida per-school choices: spell-grant, 3 spells, dependsOn school_id, divina+universal" do
    choices = build("druida")
    school_choices = choices.select { |c| c[:id].start_with?("magias-iniciais-") }
    school_choices.each do |sc|
      assert_equal "spell-grant", sc[:effectType]
      assert_equal 3, sc[:minSelections]
      assert_equal 3, sc[:maxSelections]
      assert sc[:dependsOn].present?
      assert sc[:options].length > 0
    end
  end
end
