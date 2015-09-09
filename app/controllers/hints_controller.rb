class HintsController < ApplicationController
	before_action :logged_in_user, only: [:index, :show, :destroy, :create, :index, :show, :edit, :update, :new]
	before_action :admin_user, only: [:destroy, :create, :index, :show, :edit, :update, :new]

  def new
		@hint = Hint.new
  end

	private

		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end
		
		def admin_user
      unless logged_in? && current_user.admin?
				store_location
				flash[:danger] = "Access Denied."
				redirect_to login_url
			end
    end
end
