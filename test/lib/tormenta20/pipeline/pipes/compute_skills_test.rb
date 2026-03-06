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
    s   = sheet(sheet_attributes: { "destreza" => 14 })
    ctx = run_skills(sheet: s)

    skill = ctx[:computed_skills]["acrobacia"]
    assert_equal 2, skill[:total]    # dex mod=2, no ranks, no training
    assert_equal false, skill[:trained]
  end

  test "skill trained from origin gets +2 ranks and +2 training bonus" do
    s = sheet(origin_choices: { "chosen_skills" => ["acrobacia"] },
              sheet_attributes: { "destreza" => 14 })
    ctx = run_skills(sheet: s)

    skill = ctx[:computed_skills]["acrobacia"]
    assert_equal true, skill[:trained]
    assert_equal 2,    skill[:training_bonus]
    assert_equal 6,    skill[:total]  # 2 ranks + 2 training + 2 dex mod
  end

  test "skill points from level_up are summed" do
    lu  = level_up(skill_points: { "luta" => 2 })
    s   = sheet(sheet_attributes: { "forca" => 14 })
    ctx = run_skills(sheet: s, level_ups: [lu])

    skill = ctx[:computed_skills]["luta"]
    assert_equal true, skill[:trained]
    assert_equal 6,    skill[:total]  # 2 ranks + 2 training + 2 str mod
  end

  test "skill points from multiple level_ups accumulate" do
    lu1 = level_up(level: 1, skill_points: { "atletismo" => 1 })
    lu2 = level_up(level: 2, skill_points: { "atletismo" => 1 })
    s   = sheet(sheet_attributes: { "forca" => 10 })
    ctx = run_skills(sheet: s, level_ups: [lu1, lu2])

    skill = ctx[:computed_skills]["atletismo"]
    assert_equal 2, skill[:ranks]
    assert_equal 4, skill[:total]  # 2 ranks + 2 training + 0 str mod
  end

  test "race chosen_skills bonus adds +2 to the skill" do
    s = sheet(race_choices: { "chosen_skills" => ["percepcao"] })
    ctx = run_skills(sheet: s)

    other_bonuses = ctx[:computed_skills]["percepcao"][:other_bonuses]
    race_bonus    = other_bonuses.find { |b| b[:source] == "race" }
    assert_not_nil race_bonus
    assert_equal 2, race_bonus[:value]
  end

  test "all 28 skills are computed" do
    ctx = run_skills(sheet: sheet)
    assert_equal 29, ctx[:computed_skills].size
  end
end
