if Rails.env.production?
  CarrierWave.configure do |config|
    # Configuration for Google Drive
    config.fog_credentials = {
      provider:                         'Google',
      google_storage_access_key_id:     ENV.fetch("GOOGLE_ACCESS_KEY") { "DISABLED" },
      google_storage_secret_access_key: ENV.fetch("GOOGLE_SECRET_KEY") { "DISABLED" },
    }
    config.fog_directory = ENV.fetch("GOOGLE_BUCKET") { "DISABLED" }
  end
end
