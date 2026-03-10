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
    "main_hand" => {
      "item_id" => "espada_longa_thorin", "item_key" => "espada_longa",
      "name" => "Espada Longa", "category" => "Marcial",
      "description" => "Dano 1d8 (corte). Versátil (1d10 com duas mãos).",
      "price" => "30 TO", "weight" => 2
    },
    "shield" => {
      "item_id" => "escudo_leve_thorin", "item_key" => "escudo_leve",
      "name" => "Escudo Leve", "category" => "Escudo",
      "description" => "+1 na Defesa.",
      "price" => "15 TO", "weight" => 2
    },
    "armor" => {
      "item_id" => "cota_de_malha_thorin", "item_key" => "cota_de_malha",
      "name" => "Cota de Malha", "category" => "Armadura Pesada",
      "description" => "+6 na Defesa. Des máx +2. Penalidade de armadura -5.",
      "price" => "400 TO", "weight" => 4
    }
  },
  inventory: [
    { "item_id" => "pocao_cura_thorin_1", "item_key" => "pocao_de_cura", "quantity" => 2,
      "item" => { "id" => "pocao_de_cura", "name" => "Poção de Cura",
                  "description" => "Recupera 2d6+2 PV ao beber.", "category" => "Consumível",
                  "price" => "25 TO", "weight" => 1 } },
    { "item_id" => "corda_thorin", "item_key" => "corda", "quantity" => 1,
      "item" => { "id" => "corda", "name" => "Corda (15m)",
                  "description" => "Corda de cânhamo resistente.", "category" => "Aventura",
                  "price" => "1 TO", "weight" => 2 } },
    { "item_id" => "racoes_thorin", "item_key" => "racao_de_viagem", "quantity" => 5,
      "item" => { "id" => "racao_de_viagem", "name" => "Ração de Viagem",
                  "description" => "Alimentação para um dia.", "category" => "Aventura",
                  "price" => "5 TP", "weight" => 1 } },
    { "item_id" => "tocha_thorin", "item_key" => "tocha", "quantity" => 5,
      "item" => { "id" => "tocha", "name" => "Tocha",
                  "description" => "Ilumina 9m por 1 hora.", "category" => "Aventura",
                  "price" => "1 TC", "weight" => 1 } }
  ],
  currency: { "tc" => 15, "tp" => 20, "to" => 50 }
)

setup_equipment(
  user: luan,
  name: "Lyra Sombravento",
  equipped_items: {
    "main_hand" => {
      "item_id" => "adaga_lyra_1", "item_key" => "adaga",
      "name" => "Adaga", "category" => "Simples",
      "description" => "Dano 1d4 (perfuração). Arremessável (alcance 6m).",
      "price" => "2 TO", "weight" => 1
    },
    "off_hand" => {
      "item_id" => "arco_curto_lyra", "item_key" => "arco_curto",
      "name" => "Arco Curto", "category" => "Marcial",
      "description" => "Dano 1d6 (perfuração). Alcance 30m. Munição: flechas.",
      "price" => "35 TO", "weight" => 2
    }
  },
  inventory: [
    { "item_id" => "flechas_lyra", "item_key" => "flechas", "quantity" => 20,
      "item" => { "id" => "flechas", "name" => "Flechas (20)",
                  "description" => "Munição para arco.", "category" => "Munição",
                  "price" => "1 TO", "weight" => 1 } },
    { "item_id" => "adaga_lyra_2", "item_key" => "adaga", "quantity" => 2,
      "item" => { "id" => "adaga", "name" => "Adaga",
                  "description" => "Dano 1d4 (perfuração). Arremessável.", "category" => "Simples",
                  "price" => "2 TO", "weight" => 1 } },
    { "item_id" => "ferramentas_ladrao_lyra", "item_key" => "ferramentas_de_ladrao", "quantity" => 1,
      "item" => { "id" => "ferramentas_de_ladrao", "name" => "Ferramentas de Ladrão",
                  "description" => "+2 em testes de Ladinagem com fechaduras.", "category" => "Ferramentas",
                  "price" => "25 TO", "weight" => 1 } },
    { "item_id" => "pocao_invisibilidade_lyra", "item_key" => "pocao_de_invisibilidade", "quantity" => 1,
      "item" => { "id" => "pocao_de_invisibilidade", "name" => "Poção de Invisibilidade",
                  "description" => "Torna invisível por 1 minuto.", "category" => "Consumível",
                  "price" => "120 TO", "weight" => 1 } },
    { "item_id" => "corda_lyra", "item_key" => "corda_de_seda", "quantity" => 1,
      "item" => { "id" => "corda_de_seda", "name" => "Corda de Seda (15m)",
                  "description" => "Leve e resistente.", "category" => "Aventura",
                  "price" => "10 TO", "weight" => 1 } }
  ],
  currency: { "tc" => 5, "tp" => 10, "to" => 30 }
)

setup_equipment(
  user: player,
  name: "Alaric Flamejante",
  equipped_items: {
    "main_hand" => {
      "item_id" => "cajado_alaric", "item_key" => "cajado",
      "name" => "Cajado", "category" => "Simples",
      "description" => "Dano 1d6 (impacto). Versátil (1d8).",
      "price" => "5 TP", "weight" => 2
    }
  },
  inventory: [
    { "item_id" => "bolsa_componentes_alaric", "item_key" => "bolsa_de_componentes", "quantity" => 1,
      "item" => { "id" => "bolsa_de_componentes", "name" => "Bolsa de Componentes",
                  "description" => "Componentes materiais para conjuração de magias.", "category" => "Arcano",
                  "price" => "25 TO", "weight" => 1 } },
    { "item_id" => "livro_de_magias_alaric", "item_key" => "livro_de_magias", "quantity" => 1,
      "item" => { "id" => "livro_de_magias", "name" => "Livro de Magias",
                  "description" => "Contém as fórmulas de todas as magias conhecidas.", "category" => "Arcano",
                  "price" => "50 TO", "weight" => 2 } },
    { "item_id" => "pocao_cura_alaric", "item_key" => "pocao_de_cura", "quantity" => 1,
      "item" => { "id" => "pocao_de_cura", "name" => "Poção de Cura",
                  "description" => "Recupera 2d6+2 PV ao beber.", "category" => "Consumível",
                  "price" => "25 TO", "weight" => 1 } },
    { "item_id" => "pergaminho_alaric", "item_key" => "pergaminho_de_bola_de_fogo", "quantity" => 1,
      "item" => { "id" => "pergaminho_de_bola_de_fogo", "name" => "Pergaminho: Bola de Fogo",
                  "description" => "Conjura a magia Bola de Fogo uma única vez (círculo 3).", "category" => "Consumível",
                  "price" => "90 TO", "weight" => 0 } }
  ],
  currency: { "tc" => 0, "tp" => 50, "to" => 20 }
)

setup_equipment(
  user: luan,
  name: "Seraphina Venmoor",
  equipped_items: {
    "main_hand" => {
      "item_id" => "cajado_seraphina", "item_key" => "cajado_de_cristal",
      "name" => "Cajado de Cristal", "category" => "Arcano",
      "description" => "Dano 1d6 (impacto). Foco arcano — não consome componentes de magia.",
      "price" => "150 TO", "weight" => 2
    }
  },
  inventory: [
    { "item_id" => "grimorio_seraphina", "item_key" => "grimorio", "quantity" => 1,
      "item" => { "id" => "grimorio", "name" => "Grimório Élfico",
                  "description" => "Livro de magias encadernado em couro de dragão. Contém anotações em élfico.", "category" => "Arcano",
                  "price" => "200 TO", "weight" => 2 } },
    { "item_id" => "pocao_cura_seraphina", "item_key" => "pocao_de_cura", "quantity" => 2,
      "item" => { "id" => "pocao_de_cura", "name" => "Poção de Cura",
                  "description" => "Recupera 2d6+2 PV ao beber.", "category" => "Consumível",
                  "price" => "25 TO", "weight" => 1 } },
    { "item_id" => "cristal_foco_seraphina", "item_key" => "cristal_de_foco", "quantity" => 1,
      "item" => { "id" => "cristal_de_foco", "name" => "Cristal de Foco",
                  "description" => "+1 no teste de resistência de magias ao usar como foco.", "category" => "Arcano",
                  "price" => "75 TO", "weight" => 0 } },
    { "item_id" => "bolsa_componentes_seraphina", "item_key" => "bolsa_de_componentes", "quantity" => 1,
      "item" => { "id" => "bolsa_de_componentes", "name" => "Bolsa de Componentes",
                  "description" => "Componentes materiais para conjuração de magias.", "category" => "Arcano",
                  "price" => "25 TO", "weight" => 1 } }
  ],
  currency: { "tc" => 30, "tp" => 80, "to" => 15 }
)

puts "\n  ✓ #{Tormenta20::CharacterSheet.count} personagens no total"
puts "\nSeed concluído!"
puts "  luan@arkheion.dev    / password123  (#{Tormenta20::CharacterSheet.where(user_id: luan.id).count} personagens)"
puts "  player@arkheion.dev  / password123  (#{Tormenta20::CharacterSheet.where(user_id: player.id).count} personagens)"
