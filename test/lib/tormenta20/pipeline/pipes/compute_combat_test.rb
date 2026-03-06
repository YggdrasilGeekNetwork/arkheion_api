# frozen_string_literal: true

require_relative "pipe_test_case"

class ComputeCombatTest < ActiveSupport::TestCase
  include PipeTestCase

  def run_combat(sheet:, level_ups: [], state: nil)
    ctx = build_context(sheet: sheet, level_ups: level_ups, state: state)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeCombat.call(ctx)
    ctx
  end

  # ── BAB ─────────────────────────────────────────────────────────────────────

  test "guerreiro has full BAB (1 per level)" do
    level_ups = (1..4).map { |l| level_up(class_key: "guerreiro", level: l) }
    ctx = run_combat(sheet: sheet, level_ups: level_ups)

    assert_equal 4, ctx[:computed_combat][:base_attack_bonus]
  end

  test "arcanista has poor BAB (0.5 per level, floored)" do
    lu1 = level_up(class_key: "arcanista", level: 1)
    ctx = run_combat(sheet: sheet, level_ups: [lu1])

    assert_equal 0, ctx[:computed_combat][:base_attack_bonus]

    lu2 = level_up(class_key: "arcanista", level: 2)
    ctx2 = run_combat(sheet: sheet, level_ups: [lu1, lu2])
    assert_equal 1, ctx2[:computed_combat][:base_attack_bonus]
  end

  test "unknown class uses mid BAB (0.75 per level)" do
    lu1 = level_up(class_key: "unknown_class", level: 1)
    lu2 = level_up(class_key: "unknown_class", level: 2)
    ctx = run_combat(sheet: sheet, level_ups: [lu1, lu2])

    assert_equal 1, ctx[:computed_combat][:base_attack_bonus]  # floor(1.5) = 1
  end

  # ── Melee/Ranged totals ───────────────────────────────────────────────────

  test "melee total includes BAB + STR modifier" do
    lu  = level_up(class_key: "guerreiro", level: 1)
    s   = sheet(sheet_attributes: { "forca" => 14 })
    ctx = run_combat(sheet: s, level_ups: [lu])

    assert_equal 3, ctx[:computed_combat][:melee_attack][:total]  # 1 BAB + 2 STR
  end

  test "ranged total includes BAB + DEX modifier" do
    lu  = level_up(class_key: "guerreiro", level: 1)
    s   = sheet(sheet_attributes: { "destreza" => 14 })
    ctx = run_combat(sheet: s, level_ups: [lu])

    assert_equal 3, ctx[:computed_combat][:ranged_attack][:total]  # 1 BAB + 2 DEX
  end

  # ── collect_attack_bonuses ────────────────────────────────────────────────

  test "valentao power adds +2 to melee other_bonuses" do
    lu  = level_up(powers_chosen: { "poder_de_combate" => ["valentao"] })
    ctx = run_combat(sheet: sheet, level_ups: [lu])

    melee_bonuses = ctx[:computed_combat][:melee_attack][:other_bonuses]
    assert_equal 1, melee_bonuses.size
    assert_equal 2, melee_bonuses.first[:value]
    assert_equal "Valentão", melee_bonuses.first[:label]
  end

  test "valentao power is included in melee total" do
    lu  = level_up(class_key: "guerreiro", level: 1, powers_chosen: { "poder_de_combate" => ["valentao"] })
    ctx = run_combat(sheet: sheet, level_ups: [lu])

    assert_equal 3, ctx[:computed_combat][:melee_attack][:total]  # 1 BAB + 0 STR + 2 valentao
  end

  test "ataque_acrobatico adds +2 to both melee and ranged" do
    lu  = level_up(powers_chosen: { "poder_de_combate" => ["ataque_acrobatico"] })
    ctx = run_combat(sheet: sheet, level_ups: [lu])

    assert_equal 1, ctx[:computed_combat][:melee_attack][:other_bonuses].size
    assert_equal 1, ctx[:computed_combat][:ranged_attack][:other_bonuses].size
  end

  test "powers with temporary duration are excluded from other_bonuses" do
    # escaramuca has duration: "turno" — must not appear in passive bonuses
    lu  = level_up(powers_chosen: { "poder_de_cacador" => ["escaramuca"] })
    ctx = run_combat(sheet: sheet, level_ups: [lu])

    assert_empty ctx[:computed_combat][:melee_attack][:other_bonuses]
  end

  test "no level_ups means empty other_bonuses" do
    ctx = run_combat(sheet: sheet)

    assert_empty ctx[:computed_combat][:melee_attack][:other_bonuses]
    assert_empty ctx[:computed_combat][:ranged_attack][:other_bonuses]
  end
end
