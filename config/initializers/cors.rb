# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("ALLOWED_ORIGINS", "http://localhost:5173").split(",")

    resource "*",
      headers: :any,
      methods: [ :get, :post, :options ],
      expose: []
  end
end
