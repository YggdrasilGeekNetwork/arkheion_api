# frozen_string_literal: true

require_relative "pipe_test_case"

class ComputeResourcesTest < ActiveSupport::TestCase
  include PipeTestCase

  def run_resources(sheet:, level_ups: [], state: nil)
    ctx = build_context(sheet: sheet, level_ups: level_ups, state: state)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeResources.call(ctx)
    ctx
  end

  # Guerreiro: initial_hp=20, hp_per_level=5, mp_per_level=3
  test "guerreiro level 1 PV = initial_hp + CON mod" do
    s   = sheet(sheet_attributes: { "constituicao" => 14 })
    lu  = level_up(class_key: "guerreiro", level: 1)
    ctx = run_resources(sheet: s, level_ups: [lu])

    assert_equal 22, ctx[:computed_resources][:pv][:max]  # 20 + 2 (con mod)
  end

  test "guerreiro level 2 PV adds hp_per_level + CON mod" do
    s   = sheet(sheet_attributes: { "constituicao" => 14 })
    lu1 = level_up(class_key: "guerreiro", level: 1)
    lu2 = level_up(class_key: "guerreiro", level: 2)
    ctx = run_resources(sheet: s, level_ups: [lu1, lu2])

    assert_equal 29, ctx[:computed_resources][:pv][:max]  # (20+2) + (5+2)
  end

  test "guerreiro PM = 3 per level" do
    lu1 = level_up(class_key: "guerreiro", level: 1)
    lu2 = level_up(class_key: "guerreiro", level: 2)
    ctx = run_resources(sheet: sheet, level_ups: [lu1, lu2])

    assert_equal 6, ctx[:computed_resources][:pm][:max]
  end

  test "PV is at least 1" do
    s   = sheet(sheet_attributes: { "constituicao" => 1 })  # con mod = -5
    lu  = level_up(class_key: "arcanista", level: 1)        # initial_hp low
    ctx = run_resources(sheet: s, level_ups: [lu])

    assert ctx[:computed_resources][:pv][:max] >= 1
  end

  test "movement comes from race base (humano = 9m by default)" do
    ctx = run_resources(sheet: sheet)

    deslocamento = ctx[:computed_resources][:deslocamento]
    assert deslocamento[:total] >= 3  # at least minimum
  end

  # ── PV bonuses from powers ────────────────────────────────────────────────

  # sarado: { type: "add_PV_attr", attr: "for" } — PV += STR modifier
  test "sarado adds STR modifier to PV max" do
    s  = sheet(sheet_attributes: { "forca" => 16 })  # STR mod = +3
    lu = level_up(class_key: "guerreiro", level: 1,
                  abilities_chosen: { "class_abilities" => ["sarado"] })
    lu_plain = level_up(class_key: "guerreiro", level: 1)

    ctx_with    = run_resources(sheet: s, level_ups: [lu])
    ctx_without = run_resources(sheet: s, level_ups: [lu_plain])

    pv_with    = ctx_with[:computed_resources][:pv]
    pv_without = ctx_without[:computed_resources][:pv]

    assert_equal 3, pv_with[:max] - pv_without[:max]  # +3 STR mod
    assert_equal 1, pv_with[:other_bonuses].size
    assert_equal "Sarado", pv_with[:other_bonuses].first[:label]
  end

  # vitalidade: { type: "PV_improvement", value: 1, extra_details: "por_nivel_do_personagem" }
  test "vitalidade adds 1 PV per character level" do
    lu1 = level_up(class_key: "guerreiro", level: 1,
                   abilities_chosen: { "class_abilities" => ["vitalidade"] })
    lu2 = level_up(class_key: "guerreiro", level: 2)
    lu_plain1 = level_up(class_key: "guerreiro", level: 1)
    lu_plain2 = level_up(class_key: "guerreiro", level: 2)

    ctx_with    = run_resources(sheet: sheet, level_ups: [lu1, lu2])
    ctx_without = run_resources(sheet: sheet, level_ups: [lu_plain1, lu_plain2])

    pv_with = ctx_with[:computed_resources][:pv]

    assert_equal 2, pv_with[:max] - ctx_without[:computed_resources][:pv][:max]  # 1 * 2 levels
    assert_equal 1, pv_with[:other_bonuses].size
    assert_equal "Vitalidade", pv_with[:other_bonuses].first[:label]
    assert_equal 2, pv_with[:other_bonuses].first[:value]
  end

  test "other_bonuses for PV is empty when no PV powers are chosen" do
    lu = level_up(class_key: "guerreiro", level: 1)
    ctx = run_resources(sheet: sheet, level_ups: [lu])

    assert_empty ctx[:computed_resources][:pv][:other_bonuses]
  end

  # ── PM bonuses from powers ────────────────────────────────────────────────

  # panache: { type: "PM_improvement", value: 1 } — no duration (permanent)
  test "panache adds +1 PM permanently" do
    lu_power = level_up(class_key: "guerreiro", level: 1,
                        abilities_chosen: { "class_abilities" => ["panache"] })
    lu_plain = level_up(class_key: "guerreiro", level: 1)

    ctx_with    = run_resources(sheet: sheet, level_ups: [lu_power])
    ctx_without = run_resources(sheet: sheet, level_ups: [lu_plain])

    pm_with    = ctx_with[:computed_resources][:pm]
    pm_without = ctx_without[:computed_resources][:pm]

    assert_equal 1, pm_with[:max] - pm_without[:max]
    assert_equal 1, pm_with[:other_bonuses].size
    assert_equal "Panache", pm_with[:other_bonuses].first[:label]
  end

  test "other_bonuses for PM is empty when no PM powers are chosen" do
    lu = level_up(class_key: "guerreiro", level: 1)
    ctx = run_resources(sheet: sheet, level_ups: [lu])

    assert_empty ctx[:computed_resources][:pm][:other_bonuses]
  end

  test "temporary PM improvements (duration: cena) are not included" do
    # julgamento_divino_iluminacao: PM_improvement value:2 duration:'cena'
    lu = level_up(class_key: "guerreiro", level: 1,
                  abilities_chosen: { "class_abilities" => ["julgamento_divino_iluminacao"] })
    ctx = run_resources(sheet: sheet, level_ups: [lu])

    assert_empty ctx[:computed_resources][:pm][:other_bonuses]
  end

  test "conditional PM improvements (with requirements) are not included" do
    # postura_de_combate_foco_de_batalha: PM_improvement value:1 duration:'cena' requirements:'sofrer_ataque'
    lu = level_up(class_key: "guerreiro", level: 1,
                  abilities_chosen: { "class_abilities" => ["postura_de_combate_foco_de_batalha"] })
    ctx = run_resources(sheet: sheet, level_ups: [lu])

    assert_empty ctx[:computed_resources][:pm][:other_bonuses]
  end
end
