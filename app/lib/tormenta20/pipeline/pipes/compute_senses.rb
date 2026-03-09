# frozen_string_literal: true

module Tormenta20
  module Pipeline
    module Pipes
      class ComputeSenses < BasePipe
        VISION_DISPLAY = {
          "visao_no_escuro"    => "Visão no Escuro",
          "baixa_luminosidade" => "Visão na Penumbra"
        }.freeze

        PASSIVE_SKILLS = %w[percepcao investigacao intuicao].freeze
        PASSIVE_SKILL_LABELS = {
          "percepcao"   => "Percepção Passiva",
          "investigacao" => "Investigação Passiva",
          "intuicao"    => "Intuição Passiva"
        }.freeze

        def call(context)
          senses = []
          senses += vision_senses(context)
          senses += passive_skill_senses(context)
          context[:computed_senses] = senses
          context
        end

        private

        def vision_senses(context)
          raca = race_definition(context.character_sheet.race_key)
          return [] unless raca

          label = VISION_DISPLAY[raca.vision]
          return [] unless label

          value  = raca.vision_range ? "#{raca.vision_range}m" : "18m"
          tooltip = case raca.vision
                    when "visao_no_escuro"
                      "Enxerga perfeitamente no escuro até #{value}"
                    when "baixa_luminosidade"
                      "Enxerga normalmente em iluminação fraca ou escuridão parcial"
                    end

          [{ name: label, value: value, tooltip: tooltip }]
        end

        def passive_skill_senses(context)
          skills = context[:computed_skills] || {}

          PASSIVE_SKILLS.map do |key|
            skill        = skills[key] || skills[key.to_sym] || {}
            level_bonus  = skill[:level_bonus]  || skill["level_bonus"]  || 0
            other_bonuses = skill[:other_bonuses] || skill["other_bonuses"] || []
            other_sum    = sum_bonuses(other_bonuses)
            passive      = 10 + level_bonus + other_sum
            label        = PASSIVE_SKILL_LABELS[key]
            parts = ["10 (base)", "#{level_bonus} (metade do nível)"]
            parts << "#{other_sum} (outros bônus)" if other_sum != 0
            { name: label, value: passive.to_s, tooltip: parts.join(" + ") }
          end
        end
      end
    end
  end
end
