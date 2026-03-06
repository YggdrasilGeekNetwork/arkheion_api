# frozen_string_literal: true

class AddDisplayFieldsToTormenta20Characters < ActiveRecord::Migration[8.0]
  def change
    # Fields for the frontend-facing Character type on character_sheets
    change_table :tormenta20_character_sheets do |t|
      t.string  :image_url
      t.jsonb   :classes_data,      null: false, default: []
      t.jsonb   :origin_data
      t.jsonb   :deity_data
      t.integer :max_pv
      t.integer :max_pm
      t.jsonb   :attributes_data,   null: false, default: []
      t.jsonb   :resistances_data,  null: false, default: []
      t.jsonb   :defenses_data,     null: false, default: []
      t.jsonb   :skills_data,       null: false, default: []
      t.jsonb   :abilities_data,    null: false, default: []
      t.jsonb   :spells_data,       null: false, default: []
      t.jsonb   :weapons_data,      null: false, default: []
      t.jsonb   :actions_list_data, null: false, default: []
      t.integer :character_version, null: false, default: 0
    end

    # Mutable display fields on character_states
    change_table :tormenta20_character_states do |t|
      t.jsonb   :available_actions_data,  null: false, default: {}
      t.jsonb   :equipped_items_display,  null: false, default: {}
      t.jsonb   :backpack_data,           null: false, default: []
      t.jsonb   :currencies_data,         null: false, default: {}
      t.integer :initiative_roll_value
      t.boolean :in_combat,    null: false, default: false
      t.boolean :is_my_turn,   null: false, default: false
      t.integer :turn_order,   null: false, default: 0
    end
  end
end
