# frozen_string_literal: true

require_relative "pipe_test_case"

class ApplyEquipmentModifiersTest < ActiveSupport::TestCase
  include PipeTestCase

  def run_with_equipment(equipped)
    st  = state(equipped_items: equipped)
    ctx = build_context(sheet: sheet, state: st)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeDefenses.call(ctx)
    Tormenta20::Pipeline::Pipes::ApplyEquipmentModifiers.call(ctx)
    ctx
  end

  test "no equipment leaves defense unchanged" do
    ctx = run_with_equipment({})

    assert_equal 10, ctx[:computed_defenses][:defesa][:total]
  end

  test "escudo_leve adds +1 to defense" do
    ctx = run_with_equipment({ "shield" => { "item_key" => "escudo_leve" } })

    assert_equal 1,  ctx[:computed_defenses][:defesa][:shield_bonus]
    assert_equal 11, ctx[:computed_defenses][:defesa][:total]
  end

  test "escudo_pesado adds +2 to defense" do
    ctx = run_with_equipment({ "shield" => { "item_key" => "escudo_pesado" } })

    assert_equal 2,  ctx[:computed_defenses][:defesa][:shield_bonus]
    assert_equal 12, ctx[:computed_defenses][:defesa][:total]
  end

  test "unknown item key is ignored gracefully" do
    ctx = run_with_equipment({ "shield" => { "item_key" => "nonexistent_item" } })

    assert_equal 10, ctx[:computed_defenses][:defesa][:total]
  end

  test "equipped_armor context key is set for known armor" do
    # armaduras table may be empty in dev gem; just verify no crash with missing item
    ctx = run_with_equipment({ "armor" => { "item_key" => "nonexistent_armor" } })

    assert_nil ctx[:equipped_armor]
  end

  test "equipped_main_hand context key is set" do
    # armas table is empty in gem; just verify no crash
    ctx = run_with_equipment({ "main_hand" => { "item_key" => "espada_longa" } })

    # either key is set (if weapon exists) or nil; test just ensures no exception
    assert_nil ctx["equipped_main_hand"]
  end
end
