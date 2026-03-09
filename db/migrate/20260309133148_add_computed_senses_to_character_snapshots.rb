# frozen_string_literal: true

class AddComputedSensesToCharacterSnapshots < ActiveRecord::Migration[8.0]
  def change
    add_column :tormenta20_character_snapshots, :computed_senses, :jsonb, default: [], null: false
  end
end
