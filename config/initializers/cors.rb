Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'  # ← 本番は制限すること

    resource '*',
      headers: :any,
      expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'], # ← 重要
      methods: [:get, :post, :options, :delete, :put]
  end
end