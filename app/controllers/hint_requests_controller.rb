class HintRequestsController < ApplicationController
	before_action :logged_in_user, only: :create
	before_action :belong_to_team, only: :create
	before_action :competition_active, only: :create

	def create
		points = 0
		@problem = Problem.find(params[:hint_request][:problem_id])
		@user = current_user

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
				redirect_to @problem
			end
		end

		def competition_active
			start_time = Time.parse(Setting.find_by(name: 'start_time').value)
			end_time = Time.parse(Setting.find_by(name: 'end_time').value)

			unless (start_time < Time.zone.now && Time.zone.now < end_time)
				flash[:danger] = "The competition isn't active!"
				redirect_to root_url
			end
		end
end
