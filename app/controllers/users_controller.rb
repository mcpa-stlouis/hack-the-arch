class UsersController < ApplicationController
	before_action :logged_in_user, only: [:index, :edit, :update]
	before_action :correct_user, only: [:edit, :update]
	before_action :admin_user, only: :destroy

	def show
		user = User.find(params[:id])
		if user.activated? 
			if current_user?(user)
				@user = user
			else
      	message  = "Access Denied. "
      	message += "You can only view your profile."
      	flash[:warning] = message
				redirect_to root_url
			end
		else
      message  = "Account not activated. "
      message += "Check your email for the activation link."
      flash[:warning] = message
			redirect_to root_url
		end
	end

  def new
		@user = User.new
  end

	def create
		# Validate Team first
		@user = User.new(user_params)
		@team = Team.find_by(name: params[:team][:name])
		if !@team && params[:team][:is_new_team]
			@team = Team.new(team_params)
			@team.save
		elsif @team.authenticate(params[:team][:passphrase])
			@team = Team.find_by(name: params[:team][:name])
		elsif @team && params[:team][:is_new_team]
			flash[:danger] = "Team name has been taken."
			render 'new' and return
		elsif @team.at_capacity?
			flash[:danger] = "Team has reached max capacity"
			render 'new' and return
		else
			flash[:danger] = "Team name or passphrase invalid."
			render 'new' and return
		end

		@user.team_id = @team.id

		# Validate User
		if @user.save
			@user.send_activation_email
			@team.add(@user)
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
		else
			render 'new'
		end
	end

	def destroy
		user = User.find(params[:id])
		Team.find(user.team_id).remove(user)
		@user.destroy
    flash[:success] = "User deleted"
    redirect_to users_url
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

		def team_params
			params.require(:team).permit(:name, :passphrase)
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

		def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
