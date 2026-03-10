# frozen_string_literal: true

class AddHiddenSensesToCharacterSheets < ActiveRecord::Migration[8.0]
  def change
    add_column :tormenta20_character_sheets, :hidden_senses, :jsonb, default: [], null: false
  end
end
