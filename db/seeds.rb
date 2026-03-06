# frozen_string_literal: true

# db/seeds.rb — idempotent, choices-only.
# All computed data (PV max, PM max, attributes, skills, defenses, abilities)
# is derived from the tormenta gem by the pipeline. Only choices/keys are stored.

BASE_URL = ENV.fetch("BASE_URL", "http://localhost:3000")

puts "Seeding users..."

# ─── Users ───────────────────────────────────────────────────────────────────

luan = User.find_or_create_by!(email: "luan@arkheion.dev") do |u|
  u.username     = "luan"
  u.display_name = "Luan"
  u.password     = "password123"
  u.confirmed_at = Time.current
  u.active       = true
end

player = User.find_or_create_by!(email: "player@arkheion.dev") do |u|
  u.username     = "player"
  u.display_name = "Player One"
  u.password     = "password123"
  u.confirmed_at = Time.current
  u.active       = true
end

puts "  ✓ #{User.count} users"

# ─── Helpers ─────────────────────────────────────────────────────────────────

def create_character_with_choices(user:, params:)
  name = params[:name]

  if Tormenta20::CharacterSheet.exists?(user_id: user.id, name: name)
    puts "  (skip) #{name} já existe"
    return
  end

  result = Tormenta20::Operations::Characters::Create.new.call(params: params, user: user)

  if result.success?
    presenter = result.value![:character]
    puts "  ✓ #{presenter.name} (#{presenter.classes.map { |c| "#{c[:name]} #{c[:level]}" }.join(", ")})" \
         " — PV #{presenter.max_health}, PM #{presenter.max_mana}"
  else
    puts "  ✗ Falha ao criar #{name}: #{result.failure.inspect}"
  end
end

# ─── Characters ───────────────────────────────────────────────────────────────

puts "Seeding characters..."

create_character_with_choices(
  user: luan,
  params: {
    name:       "Thorin Escudo de Ferro",
    image_url:  "#{BASE_URL}/images/characters/thorin.png",
    race_key:   "humano",
    race_choices: { "chosen_abilities" => [] },
    origin_key:  "soldado",
    origin_choices: {
      "chosen_skills" => ["luta", "fortitude"],
      "chosen_powers" => []
    },
    deity_key: "khalmyr",
    sheet_attributes: {
      "forca"        => 18,
      "destreza"     => 12,
      "constituicao" => 16,
      "inteligencia" => 8,
      "sabedoria"    => 10,
      "carisma"      => 8
    },
    first_level: {
      class_key:    "guerreiro",
      skill_points: { "luta" => 2, "atletismo" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen:    { "poder_de_guerreiro" => [] },
      spells_chosen:    { "known_spells" => [] }
    }
  }
)

create_character_with_choices(
  user: luan,
  params: {
    name:      "Lyra Sombravento",
    image_url: "#{BASE_URL}/images/characters/lyra.png",
    race_key:  "elfo",
    race_choices: { "chosen_abilities" => [] },
    origin_key:   "criminoso",
    origin_choices: {
      "chosen_skills" => ["furtividade", "ladinagem"],
      "chosen_powers" => []
    },
    deity_key: nil,
    sheet_attributes: {
      "forca"        => 10,
      "destreza"     => 20,
      "constituicao" => 12,
      "inteligencia" => 14,
      "sabedoria"    => 12,
      "carisma"      => 16
    },
    first_level: {
      class_key:    "ladino",
      skill_points: { "furtividade" => 2, "ladinagem" => 2, "acrobacia" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen:    { "poder_de_ladino" => [] },
      spells_chosen:    { "known_spells" => [] }
    }
  }
)

create_character_with_choices(
  user: player,
  params: {
    name:       "Alaric Flamejante",
    image_url:  nil,
    race_key:   "humano",
    race_choices: { "chosen_abilities" => [] },
    origin_key:   "academico",
    origin_choices: {
      "chosen_skills" => ["misticismo", "conhecimento"],
      "chosen_powers" => []
    },
    deity_key: "wynna",
    sheet_attributes: {
      "forca"        => 8,
      "destreza"     => 14,
      "constituicao" => 12,
      "inteligencia" => 20,
      "sabedoria"    => 14,
      "carisma"      => 10
    },
    first_level: {
      class_key:    "arcanista",
      skill_points: { "misticismo" => 2, "conhecimento" => 1, "investigacao" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen:    { "poder_de_arcanista" => [] },
      spells_chosen:    { "known_spells" => [] }
    }
  }
)

puts "\n  ✓ #{Tormenta20::CharacterSheet.count} personagens no total"
puts "\nSeed concluído!"
puts "  luan@arkheion.dev    / password123  (#{Tormenta20::CharacterSheet.where(user_id: luan.id).count} personagens)"
puts "  player@arkheion.dev  / password123  (#{Tormenta20::CharacterSheet.where(user_id: player.id).count} personagens)"
