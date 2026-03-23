# frozen_string_literal: true

require_relative "pipe_test_case"

class ApplyEncumbranceTest < ActiveSupport::TestCase
  include PipeTestCase

  # FOR 0 → max = 10 spaces
  BASE_SHEET = {
    sheet_attributes: {
      "forca" => 10, "destreza" => 10, "constituicao" => 10,
      "inteligencia" => 10, "sabedoria" => 10, "carisma" => 10
    }
  }.freeze

  def run_pipe(equipped: {}, inventory: [], currency: {})
    st  = state(equipped_items: equipped, inventory: inventory, currency: currency)
    ctx = build_context(sheet: sheet(BASE_SHEET), state: st)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeDefenses.call(ctx)
    Tormenta20::Pipeline::Pipes::ComputeResources.call(ctx)
    Tormenta20::Pipeline::Pipes::ApplyEncumbrance.call(ctx)
    ctx
  end

  test "no items → no encumbrance penalty" do
    ctx = run_pipe
    assert_equal 10, ctx[:computed_defenses][:defesa][:total]
    assert_nil ctx[:computed_defenses][:defesa][:encumbrance_penalty]
  end

  test "items under max → no penalty" do
    # espada_longa = 1 space, far below max=10
    ctx = run_pipe(equipped: { "main_hand" => { "item_key" => "espada_longa" } })
    assert_nil ctx[:computed_defenses][:defesa][:encumbrance_penalty]
  end

  test "items over max → -5 defense, -3 movement" do
    # cota_de_malha=5, espada_longa=1, escudo_leve=1 = 7 equipped
    # plus 4 racao_de_viagem (0.5 each = 2) + 2 tocha (1 each = 2) = 4 backpack
    # total = 11 > max=10 → overloaded
    ctx = run_pipe(
      equipped: {
        "armor"      => { "item_key" => "cota_de_malha" },
        "main_hand"  => { "item_key" => "espada_longa"  },
        "shield"     => { "item_key" => "escudo_leve"   }
      },
      inventory: [
        { "item_key" => "racao_de_viagem", "quantity" => 4 },
        { "item_key" => "tocha",           "quantity" => 2 }
      ]
    )
    assert_equal(-5, ctx[:computed_defenses][:defesa][:encumbrance_penalty])
    # base 10 + armor 6 + shield 1 - 5 encumbrance = 12
    assert_equal 12, ctx[:computed_defenses][:defesa][:total]
    assert_equal(-3, ctx[:computed_resources][:deslocamento][:encumbrance_penalty])
  end

  test "currency 1000 TO counts as 1 space" do
    # 9 items + 1 currency space = 10 = max → no penalty
    ctx = run_pipe(
      inventory: [{ "item_key" => "tocha", "quantity" => 9 }],
      currency: { "to" => 1000, "tp" => 0, "tc" => 0 }
    )
    # total = 9 + 1 = 10 = max → NOT overloaded (> max required)
    assert_nil ctx[:computed_defenses][:defesa][:encumbrance_penalty]
  end

  test "currency pushes over max → penalty applied" do
    # 10 items (each 1 space) + 1 currency space = 11 > max=10
    ctx = run_pipe(
      inventory: [{ "item_key" => "tocha", "quantity" => 10 }],
      currency: { "to" => 1000, "tp" => 0, "tc" => 0 }
    )
    assert_equal(-5, ctx[:computed_defenses][:defesa][:encumbrance_penalty])
  end

  test "FOR +2 raises max to 14, same load is fine" do
    # FOR 14 → modifier +2 → max = 10 + 4 = 14
    # 11 items → 11 < 14 → no penalty
    st  = state(
      inventory: [{ "item_key" => "tocha", "quantity" => 11 }]
    )
    ctx = build_context(
      sheet: sheet(BASE_SHEET.merge(sheet_attributes: BASE_SHEET[:sheet_attributes].merge("forca" => 14))),
      state: st
    )
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeDefenses.call(ctx)
    Tormenta20::Pipeline::Pipes::ComputeResources.call(ctx)
    Tormenta20::Pipeline::Pipes::ApplyEncumbrance.call(ctx)
    assert_nil ctx[:computed_defenses][:defesa][:encumbrance_penalty]
  end

  test "no state → no error, no penalty" do
    ctx = build_context(sheet: sheet(BASE_SHEET), state: nil)
    with_base_attributes(ctx)
    Tormenta20::Pipeline::Pipes::ComputeDefenses.call(ctx)
    Tormenta20::Pipeline::Pipes::ComputeResources.call(ctx)
    Tormenta20::Pipeline::Pipes::ApplyEncumbrance.call(ctx)
    assert_nil ctx[:computed_defenses][:defesa][:encumbrance_penalty]
  end
end
