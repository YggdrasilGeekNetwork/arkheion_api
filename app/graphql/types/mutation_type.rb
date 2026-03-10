# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Auth mutations
    field :register, mutation: Mutations::Auth::Register
    field :login, mutation: Mutations::Auth::Login
    field :refresh_tokens, mutation: Mutations::Auth::RefreshTokens
    field :logout, mutation: Mutations::Auth::Logout
    field :change_password, mutation: Mutations::Auth::ChangePassword

    # Tormenta20 Character mutations — frontend contract
    field :create_character,                    mutation: Mutations::Tormenta20::CreateCharacter
    field :delete_character,                    mutation: Mutations::Tormenta20::DeleteCharacter
    field :level_up_character,                  mutation: Mutations::Tormenta20::LevelUpCharacter
    field :update_character_health,             mutation: Mutations::Tormenta20::UpdateCharacterHealth
    field :update_character_mana,               mutation: Mutations::Tormenta20::UpdateCharacterMana
    field :update_character_hidden_senses,      mutation: Mutations::Tormenta20::UpdateCharacterHiddenSenses
    field :update_character_attributes,         mutation: Mutations::Tormenta20::UpdateCharacterAttributes
    field :update_character_resistances,        mutation: Mutations::Tormenta20::UpdateCharacterResistances
    field :update_character_defenses,           mutation: Mutations::Tormenta20::UpdateCharacterDefenses
    field :update_character_skills,             mutation: Mutations::Tormenta20::UpdateCharacterSkills
    field :update_character_abilities,          mutation: Mutations::Tormenta20::UpdateCharacterAbilities
    field :update_character_spells,             mutation: Mutations::Tormenta20::UpdateCharacterSpells
    field :update_character_weapons,            mutation: Mutations::Tormenta20::UpdateCharacterWeapons
    field :update_character_actions_list,       mutation: Mutations::Tormenta20::UpdateCharacterActionsList
    field :update_character_equipment,          mutation: Mutations::Tormenta20::UpdateCharacterEquipment
    field :update_character_currencies,         mutation: Mutations::Tormenta20::UpdateCharacterCurrencies
    field :update_character_available_actions,  mutation: Mutations::Tormenta20::UpdateCharacterAvailableActions
    field :update_character_initiative_roll,    mutation: Mutations::Tormenta20::UpdateCharacterInitiativeRoll

    # Tormenta20 Character mutations — internal / system
    field :update_character, mutation: Mutations::Tormenta20::UpdateCharacter
    field :level_up, mutation: Mutations::Tormenta20::LevelUp
    field :generate_snapshot, mutation: Mutations::Tormenta20::GenerateSnapshot

    # Tormenta20 State mutations — internal / system
    field :apply_combat_action, mutation: Mutations::Tormenta20::ApplyCombatAction
    field :manage_state, mutation: Mutations::Tormenta20::ManageState
  end
end
