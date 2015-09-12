class HintRequestsController < ApplicationController

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
				redirect_to @problem
			else
				flash[:warning] = "No more hints available!"
				redirect_to @problem
			end

		else
			flash[:danger] = "You cannot request hints unless you belong to a team!"
			redirect_to @problem
		end
	end

end
