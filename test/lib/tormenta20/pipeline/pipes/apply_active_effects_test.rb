# frozen_string_literal: true

require_relative "pipe_test_case"

class ApplyActiveEffectsTest < ActiveSupport::TestCase
  include PipeTestCase

  def run_with_effects(effects)
    st  = state(active_effects: effects)
    ctx = build_context(sheet: sheet, state: st)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeSkills.call(ctx)
    Tormenta20::Pipeline::Pipes::ComputeDefenses.call(ctx)
    Tormenta20::Pipeline::Pipes::ComputeCombat.call(ctx)
    Tormenta20::Pipeline::Pipes::ComputeResources.call(ctx)
    Tormenta20::Pipeline::Pipes::ApplyActiveEffects.call(ctx)
    ctx
  end

  test "no effects leaves totals unchanged" do
    ctx = run_with_effects([])

    assert_equal 0, ctx[:computed_combat][:melee_attack][:total]
  end

  test "attack_melee modifier is applied to melee total" do
    ctx = run_with_effects([{ "modifiers" => { "attack_melee" => 3 } }])

    assert_equal 3, ctx[:computed_combat][:melee_attack][:effect_bonus]
    assert_equal 3, ctx[:computed_combat][:melee_attack][:total]
  end

  test "attack_ranged modifier is applied to ranged total" do
    ctx = run_with_effects([{ "modifiers" => { "attack_ranged" => 2 } }])

    assert_equal 2, ctx[:computed_combat][:ranged_attack][:effect_bonus]
    assert_equal 2, ctx[:computed_combat][:ranged_attack][:total]
  end

  test "skill modifier is applied to the specific skill" do
    ctx = run_with_effects([{ "modifiers" => { "skill_percepcao" => 4 } }])

    assert_equal 4, ctx[:computed_skills]["percepcao"][:effect_bonus]
    assert_equal 4, ctx[:computed_skills]["percepcao"][:total]
  end

  test "defense modifier is applied" do
    ctx = run_with_effects([{ "modifiers" => { "defense_defesa" => 2 } }])

    assert_equal 2, ctx[:computed_defenses][:defesa][:effect_bonus]
    assert_equal 12, ctx[:computed_defenses][:defesa][:total]  # 10 base + 2 effect
  end

  test "pv_max modifier increases resource max" do
    lu  = level_up(class_key: "guerreiro", level: 1)
    st  = state(active_effects: [{ "modifiers" => { "pv_max" => 10 } }])
    ctx = build_context(sheet: sheet, level_ups: [lu], state: st)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeResources.call(ctx)
    Tormenta20::Pipeline::Pipes::ApplyActiveEffects.call(ctx)

    assert_equal 30, ctx[:computed_resources][:pv][:max]  # guerreiro initial 20 + 10
  end

  test "multiple effects stack" do
    effects = [
      { "modifiers" => { "attack_melee" => 2 } },
      { "modifiers" => { "attack_melee" => 1 } }
    ]
    ctx = run_with_effects(effects)

    assert_equal 3, ctx[:computed_combat][:melee_attack][:effect_bonus]
    assert_equal 3, ctx[:computed_combat][:melee_attack][:total]
  end
end
