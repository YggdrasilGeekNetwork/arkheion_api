# frozen_string_literal: true

require_relative "pipe_test_case"

class ComputeBaseAttributesTest < ActiveSupport::TestCase
  include PipeTestCase

  test "sets all six attributes from sheet_attributes (T20 modifier values)" do
    s = sheet(sheet_attributes: { "forca" => 2, "destreza" => 1, "constituicao" => 1,
                                   "inteligencia" => -1, "sabedoria" => 0, "carisma" => 0 })
    ctx = build_context(sheet: s)

    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(ctx)

    attrs = ctx[:computed_attributes]
    assert_equal 2,  attrs["forca"][:total]
    assert_equal 2,  attrs["forca"][:modifier]
    assert_equal 1,  attrs["destreza"][:total]
    assert_equal 1,  attrs["destreza"][:modifier]
    assert_equal(-1, attrs["inteligencia"][:modifier])
  end

  test "defaults to 0 modifier when attribute is missing" do
    ctx = build_context(sheet: sheet(sheet_attributes: {}))
    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(ctx)

    assert_equal 0, ctx[:computed_attributes]["forca"][:total]
    assert_equal 0, ctx[:computed_attributes]["forca"][:modifier]
  end

  test "modifier equals total (T20 uses modifiers directly, no D&D score conversion)" do
    s = sheet(sheet_attributes: { "forca" => 3 })
    ctx = build_context(sheet: s)
    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(ctx)

    assert_equal 3, ctx[:computed_attributes]["forca"][:total]
    assert_equal 3, ctx[:computed_attributes]["forca"][:modifier]
  end

  test "applies level-based attribute increase to modifier" do
    lu = level_up(level: 4, metadata: { "attribute_increase" => "forca" })
    s  = sheet(sheet_attributes: { "forca" => 2 })
    ctx = build_context(sheet: s, level_ups: [lu])

    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(ctx)

    assert_equal 3, ctx[:computed_attributes]["forca"][:total]
    assert_equal 3, ctx[:computed_attributes]["forca"][:modifier]
  end

  test "applies race chosen attribute bonus" do
    s = sheet(race_choices: { "chosen_attribute_bonuses" => { "forca" => 1 } })
    ctx = build_context(sheet: s)

    Tormenta20::Pipeline::Pipes::ComputeBaseAttributes.call(ctx)

    assert_equal 1, ctx[:computed_attributes]["forca"][:total]
  end
end
