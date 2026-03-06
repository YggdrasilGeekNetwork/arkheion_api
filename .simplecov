SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"

  add_group "Pipeline Pipes", "app/lib/tormenta20/pipeline/pipes"
  add_group "Operations",     "app/lib/tormenta20/operations"
  add_group "GraphQL Types",  "app/graphql/types"
  add_group "GraphQL Mutations", "app/graphql/mutations"

  # Generate lcov for CI artifact upload
  formatter SimpleCov::Formatter::HTMLFormatter
end
