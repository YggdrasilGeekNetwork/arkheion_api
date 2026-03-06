Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  get  "/graphiql", to: "graphiql#show" if Rails.env.development?

  namespace :tormenta20 do
    resources :character_sheets
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
