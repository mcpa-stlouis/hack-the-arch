require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HackTheArch
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.time_zone = ENV.fetch("TIMEZONE") { 'Central Time (US & Canada)' }
    host = ENV.fetch("HOST") { 'localhost' }
    config.action_mailer.default_url_options = { :host => host }

    # Allow Web Console
    con_host = ENV.fetch("CONSOLE_HOST") { host }
    config.action_dispatch.default_headers = {
      'Access-Control-Allow-Origin' => con_host
    } 
  end
end
