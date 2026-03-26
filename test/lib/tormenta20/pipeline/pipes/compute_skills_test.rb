# frozen_string_literal: true

require_relative "pipe_test_case"

class ComputeSkillsTest < ActiveSupport::TestCase
  include PipeTestCase

  def run_skills(sheet:, level_ups: [], state: nil)
    ctx = build_context(sheet: sheet, level_ups: level_ups, state: state)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeSkills.call(ctx)
    ctx
  end

  test "untrained skill has total equal to attribute modifier" do
    s   = sheet(sheet_attributes: { "destreza" => 2 })
    ctx = run_skills(sheet: s)

    skill = ctx[:computed_skills]["acrobacia"]
    assert_equal 2, skill[:total]    # dex mod=2, no ranks, no training
    assert_equal false, skill[:trained]
  end

  test "skill trained from origin gets +2 ranks and +2 training bonus" do
    s = sheet(origin_choices: { "chosen_skills" => ["acrobacia"] },
              sheet_attributes: { "destreza" => 2 })
    ctx = run_skills(sheet: s)

    skill = ctx[:computed_skills]["acrobacia"]
    assert_equal true, skill[:trained]
    assert_equal 2,    skill[:training_bonus]
    assert_equal 6,    skill[:total]  # 2 ranks + 2 training + 2 dex mod
  end

  test "skill points from level_up are summed" do
    lu  = level_up(skill_points: { "luta" => 2 })
    s   = sheet(sheet_attributes: { "forca" => 2 })
    ctx = run_skills(sheet: s, level_ups: [lu])

    skill = ctx[:computed_skills]["luta"]
    assert_equal true, skill[:trained]
    assert_equal 6,    skill[:total]  # 2 ranks + 2 training + 2 str mod
  end

  test "skill points from multiple level_ups accumulate" do
    lu1 = level_up(level: 1, skill_points: { "atletismo" => 1 })
    lu2 = level_up(level: 2, skill_points: { "atletismo" => 1 })
    s   = sheet(sheet_attributes: { "forca" => 0 })
    ctx = run_skills(sheet: s, level_ups: [lu1, lu2])

    skill = ctx[:computed_skills]["atletismo"]
    assert_equal 2, skill[:ranks]
    assert_equal 4, skill[:total]  # 2 ranks + 2 training + 0 str mod
  end

  test "race chosen_skills bonus adds +2 to the skill" do
    s = sheet(race_choices: { "chosen_skills" => ["percepcao"] })
    ctx = run_skills(sheet: s)

    other_bonuses = ctx[:computed_skills]["percepcao"][:other_bonuses]
    race_bonus    = other_bonuses.find { |b| b[:label] == "Raça" }
    assert_not_nil race_bonus
    assert_equal 2, race_bonus[:value]
  end

  # ── Power bonuses to skills ───────────────────────────────────────────────

  # investigador: skill_improvement investigacao +2 permanente
  test "investigador adds +2 to investigacao (skill_improvement)" do
    lu = level_up(abilities_chosen: { "class_abilities" => ["investigador"] })
    ctx = run_skills(sheet: sheet, level_ups: [lu])

    other_bonuses = ctx[:computed_skills]["investigacao"][:other_bonuses]
    assert_equal 1, other_bonuses.size
    assert_equal "Investigador", other_bonuses.first[:label]
    assert_equal 2, other_bonuses.first[:value]
  end

  # investigador: add_attr_bonus_to_skill intuicao (INT modifier)
  test "investigador adds INT modifier to intuicao (add_attr_bonus_to_skill)" do
    s  = sheet(sheet_attributes: { "inteligencia" => 3 })  # INT mod = +3
    lu = level_up(abilities_chosen: { "class_abilities" => ["investigador"] })
    ctx = run_skills(sheet: s, level_ups: [lu])

    other_bonuses = ctx[:computed_skills]["intuicao"][:other_bonuses]
    bonus = other_bonuses.find { |b| b[:label] == "Investigador" }
    assert_not_nil bonus
    assert_equal 3, bonus[:value]
  end

  test "power skill bonus does not appear for other skills" do
    lu = level_up(abilities_chosen: { "class_abilities" => ["investigador"] })
    ctx = run_skills(sheet: sheet, level_ups: [lu])

    assert_empty ctx[:computed_skills]["acrobacia"][:other_bonuses]
  end

  test "all 28 skills are computed" do
    ctx = run_skills(sheet: sheet)
    assert_equal 29, ctx[:computed_skills].size
  end
end
