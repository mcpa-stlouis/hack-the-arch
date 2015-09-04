class UsersController < ApplicationController
	before_action :logged_in_user, only: [:index, :edit, :update]
	before_action :correct_user, only: [:edit, :update]

	def index
		# TODO: List problems or teams or whatever we're going to show when the user is logged in
	end

	def show
		@user = User.find(params[:id])
	end

  def new
		@user = User.new
  end

	def create
		@user = User.new(user_params)
		if @user.save
			log_in @user
			flash[:success] = "Welcome to HackTheArch!"
			redirect_to @user
		else
			render 'new'
		end
	end

	def edit
	end

	def update
		if @user.update_attributes(user_params)
			flash[:success] = "Changes saved successfully"
			redirect_to @user
		else
			render 'edit'
		end
	end

	private
		def user_params
			params.require(:user).permit(:fname, :lname, :email, :password, :password_confirmation)
		end

		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end
		
		def correct_user
			@user = User.find(params[:id])
			redirect_to(root_url) unless current_user?(@user)
		end
end
