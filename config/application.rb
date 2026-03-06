require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ArkheionBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # GraphQL files are loaded manually in dependency order (below).
    # Zeitwerk must ignore app/graphql because many files define multiple
    # constants — Zeitwerk requires one constant per file.
    # config.autoload_paths.delete does NOT work: Rails adds app/* dirs directly
    # to Zeitwerk's scan list, bypassing autoload_paths. Use ignore() instead.
    Rails.autoloaders.main.ignore(Rails.root.join("app/graphql"))

    # Several schema files define multiple constants in one file (Zeitwerk
    # requires one constant per file). Ignore them and require explicitly so all
    # constants are available before any contract or model references them.
    %w[
      app/contracts/tormenta20/schemas/character_state_schema
      app/contracts/tormenta20/schemas/level_up_schema
      app/contracts/tormenta20/schemas/snapshot_schema
    ].each do |path|
      Rails.autoloaders.main.ignore(Rails.root.join("#{path}.rb"))
      require Rails.root.join(path)
    end

    # Eagerly load all GraphQL files at boot in dependency order.
    # Uses load() instead of require() to bypass Zeitwerk's constant validation.
    # Guard: app/graphql is excluded from Zeitwerk, so constants are never unloaded
    # between requests. Running the block twice causes DuplicateNamesError (graphql-ruby
    # detects fields registered twice when a class is reopened). Skip if already loaded.
    config.to_prepare do
      next if defined?(ArkheionSchema)

      gql = Rails.root.join("app/graphql")

      # 1. Base types (no deps)
      %w[base_argument base_field base_object base_input_object
         base_enum base_scalar base_union base_interface node_type].each do |f|
        load gql.join("types/#{f}.rb")
      end

      # 2. Tormenta20 output types (dependency order: leaves first)
      %w[
        ability_type
        attribute_value_type
        computed_attributes_type
        defense_value_type
        combat_type
        resource_value_type
        proficiencies_type
        spell_type
        skill_value_type
        level_up_type
        character_state_type
        character_snapshot_type
        character_sheet_type
        character_view_type
        character_type
        character_summary_type
        rulebook_type
      ].each { |f| load gql.join("types/tormenta20/#{f}.rb") }

      # 3. Input types
      Dir[gql.join("types/tormenta20/inputs/*.rb")].sort.each { |f| load f }

      # 4. Auth types (dependency order: user_type before auth_payload_type)
      %w[user_type auth_payload_type].each { |f| load gql.join("types/auth/#{f}.rb") }

      # 5. Mutations and queries (resolver classes must exist before root types reference them)
      # base_mutation.rb must be first — apply_combat_action.rb precedes it alphabetically
      # but inherits from BaseMutation.
      load gql.join("mutations/tormenta20/base_mutation.rb")
      Dir[gql.join("mutations/**/*.rb")].sort
                                        .reject { |f| f.end_with?("base_mutation.rb") }
                                        .each { |f| load f }
      Dir[gql.join("queries/**/*.rb")].sort.each { |f| load f }

      # 6. Query and mutation root types (reference resolver classes defined above)
      load gql.join("types/query_type.rb")
      load gql.join("types/mutation_type.rb")

      # 8. Schema (last)
      load gql.join("arkheion_schema.rb")
    end
  end
end
