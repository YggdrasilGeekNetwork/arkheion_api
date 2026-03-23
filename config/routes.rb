Rails.application.routes.draw do
  devise_for :admin_users
  ActiveAdmin.routes(self)
  post "/graphql", to: "graphql#execute"
  get  "/graphiql", to: "graphiql#show" if Rails.env.development? || ENV["ENABLE_GRAPHIQL"]

  namespace :tormenta20 do
    resources :character_sheets
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
