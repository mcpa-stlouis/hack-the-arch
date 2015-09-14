class TeamsController < ApplicationController
	before_action :member_of_team, only: [:edit, :update]
	before_action :logged_in_user, only: [:destroy, :index, :create, :show]
	before_action :admin_user, only: :destroy

	def index
		@teams = Team.paginate(page: params[:page])
		@sorted_teams = @teams.sort_by { |team| team.get_score }.reverse
	end

	def show
		@team = Team.find(params[:id])
	end

  def new
		@team = Team.new
  end
	
	def edit
	end

	def destroy
		# Remove reference from members
		@team = Team.find(params[:id])
		for user_id in @team.members_array
			user = User.find(user_id)
			user.team_id = nil
			user.save
		end
		
		@team.destroy
    flash[:success] = "Team deleted and all members removed"
    redirect_to teams_url
	end

	def update
		if @team.update_attributes(update_team_params)
			flash[:success] = "Changes saved successfully"
			redirect_to @team
		else
			render 'edit'
		end
	end

	def create
		@team = Team.new(team_params)
		@user = current_user
		@team.add(@user)
		if @team.save
			@user.team_id = @team.id
			@user.save
      flash[:success] = @team.name + " created!"
      redirect_to @team
		else
			render 'new'
		end
	end

	def remove_member
		@team = Team.find(params[:team_id])
		@user = User.find(params[:user_id])
		if !current_user.is_member?(@team)
			flash[:danger] = "You can only remove members from your team"
			redirect_to @team
		else
			@team.remove(@user)
			@user.leave_team
			flash[:success] = "Member successfully removed"
			redirect_to @team
		end
	end

	def join
		@team = Team.find(params[:team_id])
		@user = User.find(params[:user_id])
		if @user != current_user
			flash[:danger] = "You can only remove yourself"
			redirect_to @team
		elsif @user.team_id
			flash[:danger] = "You already have a team"
			redirect_to @team
		elsif !@team.authenticate(params[:passphrase])
			flash[:danger] = "Incorrect passphrase"
			redirect_to @team
		else
			if @team.add(@user) && @user.join_team(@team)
				flash[:success] = "Welcome to " + @team.name
				redirect_to @team
			else
				flash[:danger] = "Unable to join " + @team.name
				redirect_to @team
			end
		end
	end

	private
		def team_params
			params.require(:team).permit(:name, :passphrase)
		end

		def update_team_params
			params.require(:team).permit(:passphrase)
		end

		def member_of_team
			@team = Team.find(params[:id])
			redirect_to(@team) unless (current_user.is_member?(@team) || 
																 current_user.admin?)
		end

		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end

		def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
