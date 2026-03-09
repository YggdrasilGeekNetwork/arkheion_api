# frozen_string_literal: true

require_relative "pipe_test_case"

class ComputeSensesTest < ActiveSupport::TestCase
  include PipeTestCase

  def run_senses(sheet:, level_ups: [], skills: {})
    ctx = build_context(sheet: sheet, level_ups: level_ups)
    ctx[:computed_skills] = skills
    Tormenta20::Pipeline::Pipes::ComputeSenses.call(ctx)
    ctx
  end

  # ─── vision ───────────────────────────────────────────────────────────────

  test "humano has no vision sense" do
    ctx = run_senses(sheet: sheet(race_key: "humano"))
    vision_names = ctx[:computed_senses].map { |s| s[:name] }
    assert_empty(vision_names.select { |n| n.include?("Visão") })
  end

  test "anao has Visão no Escuro" do
    ctx = run_senses(sheet: sheet(race_key: "anao"))
    sense = ctx[:computed_senses].find { |s| s[:name] == "Visão no Escuro" }
    assert_not_nil sense
    assert_equal "18m", sense[:value]
  end

  test "elfo has Visão na Penumbra" do
    ctx = run_senses(sheet: sheet(race_key: "elfo"))
    sense = ctx[:computed_senses].find { |s| s[:name] == "Visão na Penumbra" }
    assert_not_nil sense
  end

  # ─── passive skills ───────────────────────────────────────────────────────

  test "passive Percepção = 10 + level_bonus + other_bonuses" do
    skills = { "percepcao" => { level_bonus: 3, other_bonuses: [{ value: 2 }] } }
    ctx = run_senses(sheet: sheet, skills: skills)
    sense = ctx[:computed_senses].find { |s| s[:name] == "Percepção Passiva" }
    assert_not_nil sense
    assert_equal "15", sense[:value]
  end

  test "passive Investigação = 10 + level_bonus only (no other bonuses)" do
    skills = { "investigacao" => { level_bonus: 3, other_bonuses: [] } }
    ctx = run_senses(sheet: sheet, skills: skills)
    sense = ctx[:computed_senses].find { |s| s[:name] == "Investigação Passiva" }
    assert_equal "13", sense[:value]
  end

  test "passive Intuição does not include training_bonus" do
    skills = { "intuicao" => { level_bonus: 2, training_bonus: 2, other_bonuses: [] } }
    ctx = run_senses(sheet: sheet, skills: skills)
    sense = ctx[:computed_senses].find { |s| s[:name] == "Intuição Passiva" }
    assert_equal "12", sense[:value]
  end

  test "passive Intuição defaults to 10 when skill is absent" do
    ctx = run_senses(sheet: sheet, skills: {})
    sense = ctx[:computed_senses].find { |s| s[:name] == "Intuição Passiva" }
    assert_equal "10", sense[:value]
  end
end
