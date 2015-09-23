if Rails.env.production?
	CarrierWave.configure do |config|
    # Configuration for Google Drive
	 	config.fog_credentials = {
   		provider:                         'Google',
   		google_storage_access_key_id:     ENV['GOOGLE_ACCESS_KEY'],
   		google_storage_secret_access_key: ENV['GOOGLE_SECRET_KEY']
  	}
   	config.fog_directory = ENV['GOOGLE_BUCKET']
  end
end
