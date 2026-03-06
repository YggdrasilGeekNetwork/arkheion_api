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

  test "other_bonuses start empty" do
    ctx = run_defenses(sheet: sheet)

    assert_empty ctx[:computed_defenses][:defesa][:other_bonuses]
    assert_empty ctx[:computed_defenses][:fortitude][:other_bonuses]
  end
end
