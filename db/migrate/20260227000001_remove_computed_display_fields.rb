# frozen_string_literal: true

class RemoveComputedDisplayFields < ActiveRecord::Migration[8.0]
  def change
    # Remove computed display fields from character_sheets.
    # These are now derived from the pipeline and served via CharacterSnapshot + CharacterPresenter.
    # Keep: image_url (user choice), character_version (snapshot cache tracking)
    remove_column :tormenta20_character_sheets, :classes_data,      :jsonb
    remove_column :tormenta20_character_sheets, :origin_data,       :jsonb
    remove_column :tormenta20_character_sheets, :deity_data,        :jsonb
    remove_column :tormenta20_character_sheets, :max_pv,            :integer
    remove_column :tormenta20_character_sheets, :max_pm,            :integer
    remove_column :tormenta20_character_sheets, :attributes_data,   :jsonb
    remove_column :tormenta20_character_sheets, :resistances_data,  :jsonb
    remove_column :tormenta20_character_sheets, :defenses_data,     :jsonb
    remove_column :tormenta20_character_sheets, :skills_data,       :jsonb
    remove_column :tormenta20_character_sheets, :abilities_data,    :jsonb
    remove_column :tormenta20_character_sheets, :spells_data,       :jsonb
    remove_column :tormenta20_character_sheets, :weapons_data,      :jsonb
    remove_column :tormenta20_character_sheets, :actions_list_data, :jsonb

    # Remove duplicate/display fields from character_states.
    # equipped_items (raw slugs) already exists; equipped_items_display was the computed version.
    # inventory and currency already exist as the canonical raw fields.
    remove_column :tormenta20_character_states, :equipped_items_display, :jsonb
    remove_column :tormenta20_character_states, :backpack_data,          :jsonb
    remove_column :tormenta20_character_states, :currencies_data,        :jsonb
  end
end
