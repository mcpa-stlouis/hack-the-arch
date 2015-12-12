class SettingsController < ApplicationController
	before_action :admin_user, only: [:index, :edit, :update]

	def edit
		@categories = Setting.uniq.pluck(:category).sort
		@settings = Setting.all.order(category: :asc, id: :asc)
		@brackets = Bracket.all.order('priority ASC')
		@users = User.all
		@teams = Team.all
	end
	
	def update
		error = false
		settings = params[:admin]
		for setting in settings
			setting = setting[1]
			to_update = Setting.find(setting[:id])

			if to_update.setting_type == 'boolean'
 				to_update.value = (setting[:value]) ? "1" : "0"
			else
				to_update.value = setting[:value]
			end

			error = (to_update.save) ? false : true
		end

		if error
			flash[:danger] = "Failed to update database. Try again."
		else
			flash[:success] = "Successfully updated changes."
		end
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
