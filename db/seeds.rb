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

def add_levels_to(user:, name:, levels:)
  sheet = Tormenta20::CharacterSheet.find_by(user_id: user.id, name: name)
  unless sheet
    puts "  (skip) #{name} não encontrado"
    return
  end

  levels_to_add = levels.drop([ sheet.current_level - 1, 0 ].max)
  if levels_to_add.empty?
    puts "  (skip) #{name} já está no nível #{sheet.current_level}"
    return
  end

  levels_to_add.each do |params|
    result = Tormenta20::Operations::LevelUps::Add.new.call(
      character_sheet_id: sheet.id,
      params: params,
      user: user
    )

    result = result.success? ? result.value! : result
    if result.success?
      sheet = result.value![:character_sheet]
      puts "  ✓ #{name} → nível #{sheet.current_level}"
    else
      puts "  ✗ Falha ao subir #{name}: #{result.failure.inspect}"
      break
    end
  end
end

def create_character_with_choices(user:, params:)
  name = params[:name]

  if Tormenta20::CharacterSheet.exists?(user_id: user.id, name: name)
    puts "  (skip) #{name} já existe"
    return
  end

  result = Tormenta20::Operations::Characters::Create.new.call(params: params, user: user)

  result = result.success? ? result.value! : result
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
    origin_key:   "estudioso",
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

create_character_with_choices(
  user: luan,
  params: {
    name:       "Seraphina Venmoor",
    image_url:  "/images/characters/seraphina.png",
    race_key:   "elfo",
    race_choices: { "chosen_abilities" => [] },
    origin_key:   "estudioso",
    origin_choices: {
      "chosen_skills" => ["misticismo", "conhecimento"],
      "chosen_powers" => []
    },
    deity_key: nil,
    sheet_attributes: {
      "forca"        => 8,
      "destreza"     => 16,
      "constituicao" => 10,
      "inteligencia" => 20,
      "sabedoria"    => 14,
      "carisma"      => 12
    },
    first_level: {
      class_key:    "arcanista",
      skill_points: { "misticismo" => 2, "investigacao" => 1, "conhecimento" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen:    { "poder_de_arcanista" => ["magia_de_animal"] },
      spells_chosen:    { "known_spells" => [] }
    }
  }
)

puts "Adicionando level ups..."

add_levels_to(
  user: luan,
  name: "Thorin Escudo de Ferro",
  levels: [
    { class_key: "guerreiro", skill_points: { "luta" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_guerreiro" => ["vitalidade"] },
      spells_chosen: { "known_spells" => [] } },
    { class_key: "guerreiro", skill_points: { "atletismo" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_guerreiro" => ["trespassar"] },
      spells_chosen: { "known_spells" => [] } },
    { class_key: "guerreiro", skill_points: { "luta" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_guerreiro" => ["aumento_de_atributo"] },
      spells_chosen: { "known_spells" => [] } },
    { class_key: "guerreiro", skill_points: {},
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_guerreiro" => ["ataque_poderoso"] },
      spells_chosen: { "known_spells" => [] } },
    { class_key: "paladino", skill_points: { "religiao" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_paladino" => ["aura_de_coragem"] },
      spells_chosen: { "known_spells" => [] } },
    { class_key: "paladino", skill_points: {},
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_paladino" => ["aumento_de_atributo"] },
      spells_chosen: { "known_spells" => [] } }
  ]
)

add_levels_to(
  user: luan,
  name: "Lyra Sombravento",
  levels: [
    { class_key: "ladino", skill_points: { "furtividade" => 1, "acrobacia" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_ladino" => ["assassinar"] },
      spells_chosen: { "known_spells" => [] } },
    { class_key: "ladino", skill_points: { "ladinagem" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_ladino" => ["emboscar"] },
      spells_chosen: { "known_spells" => [] } },
    { class_key: "ladino", skill_points: { "furtividade" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_ladino" => ["aumento_de_atributo"] },
      spells_chosen: { "known_spells" => [] } }
  ]
)

add_levels_to(
  user: player,
  name: "Alaric Flamejante",
  levels: [
    { class_key: "arcanista", skill_points: { "misticismo" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_arcanista" => ["conhecimento_magico"] },
      spells_chosen: { "known_spells" => [] } },
    { class_key: "arcanista", skill_points: { "conhecimento" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_arcanista" => ["aumento_de_atributo"] },
      spells_chosen: { "known_spells" => [] } }
  ]
)

add_levels_to(
  user: luan,
  name: "Seraphina Venmoor",
  levels: [
    { class_key: "arcanista", skill_points: { "misticismo" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_arcanista" => ["aumento_de_atributo"] },
      spells_chosen: { "known_spells" => [] } },
    { class_key: "arcanista", skill_points: { "investigacao" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_arcanista" => ["conhecimento_magico"] },
      spells_chosen: { "known_spells" => [] } },
    { class_key: "arcanista", skill_points: {},
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_arcanista" => ["mago_de_batalha"] },
      spells_chosen: { "known_spells" => [] } },
    { class_key: "arcanista", skill_points: { "misticismo" => 1 },
      abilities_chosen: { "class_abilities" => [] },
      powers_chosen: { "poder_de_arcanista" => ["aumento_de_atributo"] },
      spells_chosen: { "known_spells" => [] } }
  ]
)

# ─── Equipment ────────────────────────────────────────────────────────────────

def setup_equipment(user:, name:, equipped_items: {}, inventory: [], currency: {})
  sheet = Tormenta20::CharacterSheet.find_by(user_id: user.id, name: name)
  unless sheet
    puts "  (skip) #{name} não encontrado"
    return
  end

  state = sheet.character_state
  unless state
    puts "  (skip) #{name} sem estado"
    return
  end

  state.update!(equipped_items: equipped_items, inventory: inventory, currency: currency)
  Tormenta20::Operations::Snapshots::Generate.new.call(character_sheet: sheet.reload, force: true)
  puts "  ✓ #{name} equipado"
rescue => e
  puts "  ✗ Falha ao equipar #{name}: #{e.message}"
end

puts "Adicionando equipamentos..."

setup_equipment(
  user: luan,
  name: "Thorin Escudo de Ferro",
  equipped_items: {
    "main_hand" => { "item_key" => "espada_longa" },
    "shield"    => { "item_key" => "escudo_leve" },
    "armor"     => { "item_key" => "cota_de_malha" }
  },
  inventory: [
    { "item_id" => "balsamo_restaurador", "item_key" => "balsamo_restaurador", "quantity" => 2 },
    { "item_id" => "corda",               "item_key" => "corda",               "quantity" => 1 },
    { "item_id" => "racao_de_viagem",     "item_key" => "racao_de_viagem",     "quantity" => 5 },
    { "item_id" => "tocha",               "item_key" => "tocha",               "quantity" => 5 }
  ],
  currency: { "tc" => 15, "tp" => 20, "to" => 50 }
)

setup_equipment(
  user: luan,
  name: "Lyra Sombravento",
  equipped_items: {
    "main_hand" => { "item_key" => "adaga" },
    "off_hand"  => { "item_key" => "arco_curto" }
  },
  inventory: [
    { "item_id" => "adaga",              "item_key" => "adaga",              "quantity" => 2 },
    { "item_id" => "gazua",              "item_key" => "gazua",              "quantity" => 1 },
    { "item_id" => "balsamo_restaurador", "item_key" => "balsamo_restaurador", "quantity" => 1 },
    { "item_id" => "corda",              "item_key" => "corda",              "quantity" => 1 },
    { "item_id" => "essencia_de_sombra", "item_key" => "essencia_de_sombra", "quantity" => 1 }
  ],
  currency: { "tc" => 5, "tp" => 10, "to" => 30 }
)

setup_equipment(
  user: player,
  name: "Alaric Flamejante",
  equipped_items: {
    "main_hand" => { "item_key" => "bordao" },
    "slot1"     => { "item_key" => "cajado_arcano" }
  },
  inventory: [
    { "item_id" => "tomo_hermetico",     "item_key" => "tomo_hermetico",     "quantity" => 1 },
    { "item_id" => "balsamo_restaurador", "item_key" => "balsamo_restaurador", "quantity" => 1 },
    { "item_id" => "essencia_de_mana",   "item_key" => "essencia_de_mana",   "quantity" => 2 },
    { "item_id" => "bolsa_de_po",        "item_key" => "bolsa_de_po",        "quantity" => 1 }
  ],
  currency: { "tc" => 0, "tp" => 50, "to" => 20 }
)

setup_equipment(
  user: luan,
  name: "Seraphina Venmoor",
  equipped_items: {
    "main_hand" => { "item_key" => "bordao" },
    "slot1"     => { "item_key" => "cajado_arcano" }
  },
  inventory: [
    { "item_id" => "tomo_hermetico",     "item_key" => "tomo_hermetico",     "quantity" => 1 },
    { "item_id" => "balsamo_restaurador", "item_key" => "balsamo_restaurador", "quantity" => 2 },
    { "item_id" => "orbe_cristalino",    "item_key" => "orbe_cristalino",    "quantity" => 1 },
    { "item_id" => "robe_mistico",       "item_key" => "robe_mistico",       "quantity" => 1 }
  ],
  currency: { "tc" => 30, "tp" => 80, "to" => 15 }
)

puts "\n  ✓ #{Tormenta20::CharacterSheet.count} personagens no total"
puts "\nSeed concluído!"
puts "  luan@arkheion.dev    / password123  (#{Tormenta20::CharacterSheet.where(user_id: luan.id).count} personagens)"
puts "  player@arkheion.dev  / password123  (#{Tormenta20::CharacterSheet.where(user_id: player.id).count} personagens)"
