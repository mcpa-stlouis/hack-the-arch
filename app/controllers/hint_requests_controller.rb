class HintRequestsController < ApplicationController
	before_action :belong_to_team, only: [:index, :show]
	before_action :logged_in_user, only: [:index, :show]

	def create
		points = 0
		@problem = Problem.find(params[:hint_request][:problem_id])
		@user = current_user
		if @user.team_id

			@team = Team.find(@user.team_id)
			hints_requested = @team.get_hints_requested(@problem.id)

			if ((!hints_requested || 
					 hints_requested.count < @problem.number_of_hints_available) &&
					 @problem.number_of_hints_available > 0 )

				@hint = Hint.find(@problem.get_next_hint(@team.id, @problem.id))


				HintRequest.create(team_id:  @user.team_id,
 						 						 	user_id: @user.id,
 						 						 	problem_id: @problem.id,
												 	hint_id:	@hint.id,
 						 						 	points:	@hint.points)
				redirect_to controller: 'problems', action: 'index', problem_id: @problem.id
			else
				flash[:warning] = "No more hints available!"
				redirect_to controller: 'problems', action: 'index', problem_id: @problem.id
			end

		else
			flash[:danger] = "You cannot request hints unless you belong to a team!"
			redirect_to controller: 'problems', action: 'index', problem_id: @problem.id
		end
	end

	private

		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end
		
		def belong_to_team
			unless current_user.team_id
				flash[:danger] = "You must belong to a team to view the problems!"
				redirect_to current_user
			end
		end
		

end
