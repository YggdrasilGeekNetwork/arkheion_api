# frozen_string_literal: true

require "test_helper"
require_relative "../lib/tormenta20/operations/operation_test_case"

class UpdateCharacterEquipmentTest < ActiveSupport::TestCase
  include OperationTestCase

  MUTATION = <<~GQL
    mutation($id: ID!, $equippedItems: EquippedItemsInput!, $backpack: [EquipmentItemInput!]!) {
      updateCharacterEquipment(id: $id, equippedItems: $equippedItems, backpack: $backpack) {
        __typename
      }
    }
  GQL

  setup do
    @user    = create_user
    @warrior = create_character(user: @user)
  end

  test "persists equipped item_key to main_hand slot" do
    execute(
      equipped_items: { rightHand: { id: "espada_longa", name: "Espada Longa" } },
      backpack: []
    )

    state = @warrior.character_state.reload
    assert_equal "espada_longa", state.equipped_items.dig("main_hand", "item_key")
  end

  test "persists backpack items to inventory" do
    execute(
      equipped_items: {},
      backpack: [{ id: "pocao_de_cura", name: "Poção de Cura", quantity: 3 }]
    )

    state = @warrior.character_state.reload
    assert_equal 1, state.inventory.length
    assert_equal "pocao_de_cura", state.inventory.first["item_key"]
    assert_equal 3, state.inventory.first["quantity"]
  end

  test "maps left_hand to off_hand" do
    execute(
      equipped_items: { leftHand: { id: "escudo_leve", name: "Escudo Leve" } },
      backpack: []
    )

    state = @warrior.character_state.reload
    assert_equal "escudo_leve", state.equipped_items.dig("off_hand", "item_key")
  end

  test "clears slot when item is not sent" do
    @warrior.character_state.update_column(:equipped_items, { "main_hand" => { "item_key" => "espada_longa" } })

    execute(equipped_items: {}, backpack: [])

    state = @warrior.character_state.reload
    assert_nil state.equipped_items["main_hand"]
  end

  private

  def execute(equipped_items:, backpack:)
    result = ArkheionSchema.execute(
      MUTATION,
      variables: { id: @warrior.id, equippedItems: equipped_items, backpack: backpack },
      context: { current_user: @user }
    )
    result.dig("data", "updateCharacterEquipment")
  end

  def create_character(user:)
    result = Tormenta20::Operations::Characters::Create.new.call(
      params: valid_character_params(first_level: valid_first_level_params(class_key: "guerreiro")),
      user: user
    )
    inner = result.success? ? result.value! : result
    assert inner.success?, "Character creation failed: #{inner.failure.inspect}"
    inner.value![:character].sheet
  end
end
