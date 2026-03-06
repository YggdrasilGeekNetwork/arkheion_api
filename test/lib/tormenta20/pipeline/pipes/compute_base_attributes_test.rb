# frozen_string_literal: true

require_relative "pipe_test_case"

class ComputeBaseAttributesTest < ActiveSupport::TestCase
  include PipeTestCase

  test "sets all six attributes from sheet_attributes" do
    s = sheet(sheet_attributes: { "forca" => 14, "destreza" => 12, "constituicao" => 13,
                                   "inteligencia" => 8, "sabedoria" => 10, "carisma" => 10 })
    ctx = build_context(sheet: s)

    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(ctx)

    attrs = ctx[:computed_attributes]
    assert_equal 14, attrs["forca"][:total]
    assert_equal 2,  attrs["forca"][:modifier]
    assert_equal 12, attrs["destreza"][:total]
    assert_equal 1,  attrs["destreza"][:modifier]
    assert_equal(-1, attrs["inteligencia"][:modifier])
  end

  test "defaults to 10 when attribute is missing" do
    ctx = build_context(sheet: sheet(sheet_attributes: {}))
    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(ctx)

    assert_equal 10, ctx[:computed_attributes]["forca"][:total]
    assert_equal 0,  ctx[:computed_attributes]["forca"][:modifier]
  end

  test "applies level-based attribute increase" do
    lu = level_up(level: 4, metadata: { "attribute_increase" => "forca" })
    s  = sheet(sheet_attributes: { "forca" => 14 })
    ctx = build_context(sheet: s, level_ups: [lu])

    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(ctx)

    assert_equal 15, ctx[:computed_attributes]["forca"][:total]
  end

  test "applies race chosen attribute bonus" do
    s = sheet(race_choices: { "chosen_attribute_bonuses" => { "forca" => 2 } })
    ctx = build_context(sheet: s)

    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(ctx)

    assert_equal 12, ctx[:computed_attributes]["forca"][:total]
  end

  test "modifier formula is (total - 10) / 2 (integer division)" do
    s = sheet(sheet_attributes: { "forca" => 15 })
    ctx = build_context(sheet: s)
    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(ctx)

    assert_equal 2, ctx[:computed_attributes]["forca"][:modifier]

    s2 = sheet(sheet_attributes: { "forca" => 16 })
    ctx2 = build_context(sheet: s2)
    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(ctx2)

    assert_equal 3, ctx2[:computed_attributes]["forca"][:modifier]
  end
end
