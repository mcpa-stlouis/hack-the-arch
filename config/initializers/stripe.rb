
Rails.configuration.stripe = {
  publishable_key: ENV.fetch("STRIPE_PUBLISHABLE_KEY") { "DISABLED" },
  secret_key:      ENV.fetch("STRIPE_SECRET_KEY") { "DISABLED" }
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
