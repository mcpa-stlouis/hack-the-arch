class TeamsController < ApplicationController
	before_action :logged_in_user, only: [:create, :show, :destroy, :edit, :update]
	before_action :member_of_team, only: [:destroy, :edit, :update]

	def index
		# reject admins
		@teams = Team.where.not(name: 'admins')
		@brackets = Bracket.all
	end

	def show
		@team = Team.find(params[:id])
		@bracket = Bracket.find(@team.bracket_id)
		@members = @team.users.sort_by { |user| user.get_score }.reverse
		if !current_user.admin? && params[:id] == 1
			flash[:danger] = "Access Denied"
			redirect_to root_url
		end	
	end

  def new
		@team = Team.new
  end
	
	def edit
	end

	def destroy
		@team.destroy
    flash[:success] = "Team deleted and all members removed"
    redirect_to teams_url
	end

	def update
		if @team.update_attributes(team_params)
			flash[:success] = "Changes saved successfully"
			redirect_to @team
		else
			render 'edit'
		end
	end

	def create
		@user = current_user
		@team = Team.new(team_params)
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
		if !current_user.team == @team && !current_user.admin?
			flash[:danger] = "You can only remove members from your team"
			redirect_to @team
		else
			@user.leave_team
			flash[:success] = "Member successfully removed"
			redirect_to @team
		end
	end

	def join
		@team = Team.find(params[:team_id])
		@user = User.find(params[:user_id])
		if @user != current_user
			flash[:danger] = "You can only add yourself"
			redirect_to @team
		elsif @user.team_id
			flash[:danger] = "You already have a team"
			redirect_to @team
		elsif !@team.authenticate(params[:passphrase])
			flash[:danger] = "Incorrect passphrase"
			redirect_to @team
		elsif @team.id == 1 && @user.id != 1
			flash[:danger] = "Access denied"
			redirect_to root_url
		else
			if @user.join_team(@team)
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
			params.require(:team).permit(:name, :passphrase, :bracket_id)
		end

		def member_of_team
			@team = Team.find(params[:id])
			unless current_user.team == @team || current_user.admin?
				flash[:danger] = "Access denied"
				redirect_to root_url
			end
		end

		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end
end
