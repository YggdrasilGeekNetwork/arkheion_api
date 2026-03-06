# frozen_string_literal: true

class CreateTormenta20CharacterSheets < ActiveRecord::Migration[7.1]
  def change
    create_table :tormenta20_character_sheets, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.uuid :campaign_id  # FK added when campaigns table is created

      # Queryable fields
      t.string :name, null: false
      t.string :race_key, null: false
      t.string :origin_key, null: false
      t.string :deity_key

      # Baseline data stored as JSONB
      t.jsonb :attributes, null: false, default: {}
      t.jsonb :race_choices, null: false, default: {}
      t.jsonb :origin_choices, null: false, default: {}
      t.jsonb :proficiencies, null: false, default: {}
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :tormenta20_character_sheets, :name
    add_index :tormenta20_character_sheets, :race_key
    add_index :tormenta20_character_sheets, %i[user_id campaign_id]
  end
end
