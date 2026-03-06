# frozen_string_literal: true

class RenameAttributesToSheetAttributesInCharacterSheets < ActiveRecord::Migration[8.0]
  def change
    rename_column :tormenta20_character_sheets, :attributes, :sheet_attributes
  end
end
