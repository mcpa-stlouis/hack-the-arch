class TeamsController < ApplicationController
	before_action :is_member_of_team, only: [:edit, :update]

	def show
		team = Team.find(params[:id])
		user = current_user
		if !user.activated? 
      message  = "Account not activated. "
      message += "Check your email for the activation link."
      flash[:warning] = message
			redirect_to root_url
		end
	end

  def new
		@team = Team.new
  end
	
	def create
		@team = Team.new(team_params)
		if @team.save
			flash[:success] = "Team created and you have been added!"
			redirect_to @team
		else
			render 'user/new'
		end
	end

	def edit
	end

	def update
		if @team.update_attributes(team_params)
			flash[:success] = "Changes saved successfully"
			redirect_to @team
		else
			render 'edit'
		end
	end

	private
		def team_params
			params.require(:team).permit(:user, :team, :passphrase)
		end

		def is_member_of_team
			@team = Team.find(params[:id]
			redirect_to(@team) unless is_member?(@team, current_user) ||
																current_user.admin?
		end
end
