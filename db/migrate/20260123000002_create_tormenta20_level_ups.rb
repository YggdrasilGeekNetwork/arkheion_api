# frozen_string_literal: true

class CreateTormenta20LevelUps < ActiveRecord::Migration[7.1]
  def change
    create_table :tormenta20_level_ups, id: :uuid do |t|
      t.references :character_sheet,
                   null: false,
                   foreign_key: { to_table: :tormenta20_character_sheets },
                   type: :uuid

      t.integer :level, null: false
      t.string :class_key, null: false

      # Level up choices stored as JSONB
      t.jsonb :class_choices, null: false, default: {}
      t.jsonb :skill_points, null: false, default: {}
      t.jsonb :abilities_chosen, null: false, default: {}
      t.jsonb :powers_chosen, null: false, default: {}
      t.jsonb :spells_chosen, null: false, default: {}
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :tormenta20_level_ups, %i[character_sheet_id level], unique: true
    add_index :tormenta20_level_ups, :class_key
    add_index :tormenta20_level_ups, :level
  end
end
