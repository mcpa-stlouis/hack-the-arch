class SettingsController < ApplicationController
	before_action :admin_user, only: [:edit, :update]

	def edit
		@settings = Setting.all
	end
	
	def update
		error = false
		settings = params[:admin]
		for setting in settings
			setting = setting[1]
			to_update = Setting.find(setting[:id])
			if to_update.value != setting[:value]
				to_update.value = setting[:value]
				if !to_update.save
					error = true
				end
			end
		end
		if error
			flash[:danger] = "Failed to update database. Try again."
		else
			flash[:success] = "Successfully updated changes."
		end
		redirect_to admin_url
	end

	def index
		redirect_to admin_url
	end

	private
		def admin_user
      unless logged_in? && current_user.admin?
				store_location
				flash[:danger] = "Access Denied."
				redirect_to root_url
			end
    end
end
