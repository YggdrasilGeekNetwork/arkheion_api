# frozen_string_literal: true

class CreateTormenta20CharacterSnapshots < ActiveRecord::Migration[7.1]
  def change
    create_table :tormenta20_character_snapshots, id: :uuid do |t|
      t.references :character_sheet,
                   null: false,
                   foreign_key: { to_table: :tormenta20_character_sheets },
                   type: :uuid

      t.integer :version, null: false
      t.string :checksum, null: false

      # All calculated/derived values cached here
      t.jsonb :computed_attributes, null: false, default: {}
      t.jsonb :computed_defenses, null: false, default: {}
      t.jsonb :computed_skills, null: false, default: {}
      t.jsonb :computed_combat, null: false, default: {}
      t.jsonb :computed_resources, null: false, default: {}
      t.jsonb :computed_abilities, null: false, default: {}
      t.jsonb :computed_spells, null: false, default: {}
      t.jsonb :computed_proficiencies, null: false, default: {}
      t.jsonb :full_snapshot, null: false, default: {}

      t.datetime :computed_at, null: false

      t.timestamps
    end

    add_index :tormenta20_character_snapshots, %i[character_sheet_id version], unique: true, name: 'idx_snapshots_on_sheet_and_version'
    add_index :tormenta20_character_snapshots, :checksum
    add_index :tormenta20_character_snapshots, :computed_at
  end
end
