# frozen_string_literal: true

require_relative "pipe_test_case"

class ComputeDefensesTest < ActiveSupport::TestCase
  include PipeTestCase

  def run_defenses(sheet:, level_ups: [], state: nil)
    ctx = build_context(sheet: sheet, level_ups: level_ups, state: state)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeDefenses.call(ctx)
    ctx
  end

  test "base defense = 10 + dex modifier" do
    s   = sheet(sheet_attributes: { "destreza" => 14 })
    ctx = run_defenses(sheet: s)

    assert_equal 12, ctx[:computed_defenses][:defesa][:total]  # 10 + 2
  end

  test "fortitude uses constituicao modifier" do
    s   = sheet(sheet_attributes: { "constituicao" => 14 })
    ctx = run_defenses(sheet: s)

    assert_equal 2, ctx[:computed_defenses][:fortitude][:total]
  end

  test "reflexos uses destreza modifier" do
    s   = sheet(sheet_attributes: { "destreza" => 16 })
    ctx = run_defenses(sheet: s)

    assert_equal 3, ctx[:computed_defenses][:reflexos][:total]
  end

  test "vontade uses sabedoria modifier" do
    s   = sheet(sheet_attributes: { "sabedoria" => 12 })
    ctx = run_defenses(sheet: s)

    assert_equal 1, ctx[:computed_defenses][:vontade][:total]
  end

  test "shield adds to defense (escudo_leve = +1)" do
    st  = state(equipped_items: { "shield" => { "item_key" => "escudo_leve" } })
    ctx = build_context(sheet: sheet, state: st)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeDefenses.call(ctx)
    Tormenta20::Pipeline::Pipes::ApplyEquipmentModifiers.call(ctx)

    assert_equal 11, ctx[:computed_defenses][:defesa][:total]  # 10 + 0 dex + 1 shield
  end

  test "other_bonuses are empty when no bonus powers are chosen" do
    ctx = run_defenses(sheet: sheet)

    assert_empty ctx[:computed_defenses][:defesa][:other_bonuses]
    assert_empty ctx[:computed_defenses][:fortitude][:other_bonuses]
    assert_empty ctx[:computed_defenses][:reflexos][:other_bonuses]
    assert_empty ctx[:computed_defenses][:vontade][:other_bonuses]
  end

  # ── Defense bonuses from powers ───────────────────────────────────────────

  # esquiva: defense_improvement +2 permanente + expertise_improvement reflexos +2 permanente
  test "esquiva adds +2 to Defesa" do
    lu_with  = level_up(abilities_chosen: { "class_abilities" => ["esquiva"] })
    lu_plain = level_up

    ctx_with    = run_defenses(sheet: sheet, level_ups: [lu_with])
    ctx_without = run_defenses(sheet: sheet, level_ups: [lu_plain])

    defesa = ctx_with[:computed_defenses][:defesa]

    assert_equal 2, defesa[:total] - ctx_without[:computed_defenses][:defesa][:total]
    assert_equal 1, defesa[:other_bonuses].size
    assert_equal "Esquiva", defesa[:other_bonuses].first[:label]
  end

  test "esquiva adds +2 to Reflexos (expertise_improvement)" do
    lu = level_up(abilities_chosen: { "class_abilities" => ["esquiva"] })
    ctx = run_defenses(sheet: sheet, level_ups: [lu])

    reflexos = ctx[:computed_defenses][:reflexos]

    assert_equal 1, reflexos[:other_bonuses].size
    assert_equal "Esquiva", reflexos[:other_bonuses].first[:label]
    assert_equal 2, reflexos[:other_bonuses].first[:value]
  end

  # vitalidade: skill_improvement fortitude +2 permanente
  test "vitalidade adds +2 to Fortitude (skill_improvement)" do
    lu = level_up(abilities_chosen: { "class_abilities" => ["vitalidade"] })
    ctx = run_defenses(sheet: sheet, level_ups: [lu])

    fortitude = ctx[:computed_defenses][:fortitude]

    assert_equal 1, fortitude[:other_bonuses].size
    assert_equal "Vitalidade", fortitude[:other_bonuses].first[:label]
    assert_equal 2, fortitude[:other_bonuses].first[:value]
  end

  # vontade_de_ferro: skill_improvement vontade +2 permanente
  test "vontade_de_ferro adds +2 to Vontade (skill_improvement)" do
    lu = level_up(abilities_chosen: { "class_abilities" => ["vontade_de_ferro"] })
    ctx = run_defenses(sheet: sheet, level_ups: [lu])

    vontade = ctx[:computed_defenses][:vontade]

    assert_equal 1, vontade[:other_bonuses].size
    assert_equal "Vontade de Ferro", vontade[:other_bonuses].first[:label]
    assert_equal 2, vontade[:other_bonuses].first[:value]
  end

  test "temporary defense_improvement (duration != permanente) is not included" do
    # combate_defensivo: defense_improvement +5 duration:proximo_turno
    lu = level_up(abilities_chosen: { "class_abilities" => ["combate_defensivo"] })
    ctx = run_defenses(sheet: sheet, level_ups: [lu])

    assert_empty ctx[:computed_defenses][:defesa][:other_bonuses]
  end
end
