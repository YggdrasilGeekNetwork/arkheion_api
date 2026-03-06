# frozen_string_literal: true

class CreateTormenta20CharacterStates < ActiveRecord::Migration[7.1]
  def change
    create_table :tormenta20_character_states, id: :uuid do |t|
      t.references :character_sheet,
                   null: false,
                   foreign_key: { to_table: :tormenta20_character_sheets },
                   type: :uuid

      # Current resource values (mutable during play)
      t.integer :current_pv, null: false, default: 0
      t.integer :current_pm, null: false, default: 0
      t.integer :temporary_pv, null: false, default: 0

      # Transient/session state as JSONB
      t.jsonb :equipped_items, null: false, default: {}
      t.jsonb :active_conditions, null: false, default: []
      t.jsonb :active_effects, null: false, default: []
      t.jsonb :consumable_uses, null: false, default: {}
      t.jsonb :spell_slots_used, null: false, default: {}
      t.jsonb :ability_uses, null: false, default: {}
      t.jsonb :inventory, null: false, default: []
      t.jsonb :currency, null: false, default: {}
      t.jsonb :notes, null: false, default: {}

      t.timestamps
    end
  end
end
