# frozen_string_literal: true

require_relative "pipe_test_case"

class ComputeSpellsTest < ActiveSupport::TestCase
  include PipeTestCase

  def run_spells(sheet:, level_ups: [])
    ctx = build_context(sheet: sheet, level_ups: level_ups)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeSpells.call(ctx)
    ctx
  end

  # ─── spellcasting_attribute ──────────────────────────────────────────────

  test "spellcasting_attribute is nil for non-caster" do
    ctx = run_spells(sheet: sheet, level_ups: [level_up(class_key: "guerreiro")])
    assert_nil ctx[:computed_spells][:spellcasting_attribute]
  end

  test "spellcasting_attribute is inteligencia for arcanista" do
    ctx = run_spells(sheet: sheet, level_ups: [level_up(class_key: "arcanista")])
    assert_equal "inteligencia", ctx[:computed_spells][:spellcasting_attribute]
  end

  test "spellcasting_attribute is sabedoria for clerigo" do
    ctx = run_spells(sheet: sheet, level_ups: [level_up(class_key: "clerigo")])
    assert_equal "sabedoria", ctx[:computed_spells][:spellcasting_attribute]
  end

  test "spellcasting_attribute is carisma for bardo" do
    ctx = run_spells(sheet: sheet, level_ups: [level_up(class_key: "bardo")])
    assert_equal "carisma", ctx[:computed_spells][:spellcasting_attribute]
  end

  # ─── save_dc ─────────────────────────────────────────────────────────────

  test "save_dc is nil for non-caster" do
    ctx = run_spells(sheet: sheet, level_ups: [level_up(class_key: "guerreiro")])
    assert_nil ctx[:computed_spells][:save_dc]
  end

  test "save_dc total = 10 + INT modifier for arcanista" do
    # INT 18 → modifier +4
    s = sheet(sheet_attributes: { "forca" => 0, "destreza" => 0, "constituicao" => 0,
                                  "inteligencia" => 4, "sabedoria" => 0, "carisma" => 10 })
    ctx = run_spells(sheet: s, level_ups: [level_up(class_key: "arcanista")])
    assert_equal 14, ctx[:computed_spells][:save_dc][:total]
  end

  test "save_dc includes permanent CD_improvement power bonus" do
    # "fortalecimento_arcano" has a permanent CD_improvement of +1
    s = sheet(sheet_attributes: { "forca" => 0, "destreza" => 0, "constituicao" => 0,
                                  "inteligencia" => 0, "sabedoria" => 0, "carisma" => 10 })
    lu = level_up(class_key: "arcanista",
                  powers_chosen: { "poder_de_arcanista" => ["fortalecimento_arcano"] })
    ctx = run_spells(sheet: s, level_ups: [lu])
    save_dc = ctx[:computed_spells][:save_dc]
    # 10 (base) + 0 (INT mod) + 1 (fortalecimento_arcano) = 11
    assert_equal 11, save_dc[:total]
    assert_equal 1, save_dc[:other_bonuses].length
  end

  test "save_dc conditional bonus not included in total but listed separately" do
    # "especialista_em_escola" has a conditional CD_improvement of +2 (only for chosen school)
    s = sheet(sheet_attributes: { "forca" => 0, "destreza" => 0, "constituicao" => 0,
                                  "inteligencia" => 0, "sabedoria" => 0, "carisma" => 10 })
    lu = level_up(class_key: "arcanista",
                  powers_chosen: { "poder_de_arcanista" => ["especialista_em_escola"] })
    ctx = run_spells(sheet: s, level_ups: [lu])
    save_dc = ctx[:computed_spells][:save_dc]
    assert_equal 10, save_dc[:total]  # conditional bonus NOT included
    assert_empty save_dc[:other_bonuses]
    assert_equal 1, save_dc[:conditional_bonuses].length
    assert_equal "+2", "+#{save_dc[:conditional_bonuses][0][:value]}"
  end

  # ─── spell_slots ─────────────────────────────────────────────────────────

  test "non-caster has zero spell slots" do
    ctx = run_spells(sheet: sheet, level_ups: [level_up(class_key: "guerreiro")])
    assert_equal 0, ctx[:computed_spells][:spell_slots].values.sum
  end

  test "arcanista level 1 has 1 first-circle slot" do
    ctx = run_spells(sheet: sheet, level_ups: [level_up(class_key: "arcanista", level: 1)])
    assert_equal 1, ctx[:computed_spells][:spell_slots][1]
    assert_equal 0, ctx[:computed_spells][:spell_slots][2]
  end

  test "arcanista level 3 gains second-circle slot" do
    lus = (1..3).map { |l| level_up(class_key: "arcanista", level: l) }
    ctx = run_spells(sheet: sheet, level_ups: lus)
    assert_equal 1, ctx[:computed_spells][:spell_slots][2]
  end
end
