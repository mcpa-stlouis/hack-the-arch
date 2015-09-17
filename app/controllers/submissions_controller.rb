class SubmissionsController < ApplicationController
	before_action :user_logged_in, only: [:create, :new]
	before_action :belong_to_team, only: [:index]
	before_action :competition_active, only: [:create, :new]

	def new
	end

	def create
		correct = false
		points = 0
		solution = params[:submission][:value]
		@problem = Problem.find(params[:submission][:id])

		# If the solution is correct
		if solution == @problem.solution
			correct = true

			# And it has not already been solved
			if @problem.solved_by?(current_user.team_id)
				flash[:warning] = "Your team has already solved this!"
				redirect_to problems_path
			else
				flash[:success] = @problem.correct_message
				points = @problem.points
				redirect_to problems_path
			end

		# Or the answer has already been guessed
		elsif ( Submission.find_by(team_id: current_user.team_id,
														 	submission: solution) )
			flash[:warning] = "Your team has already guessed that!"
			redirect_to @problem
		else
			flash[:danger] = @problem.false_message
			redirect_to @problem
		end
		Submission.create(team_id:  current_user.team_id,
					 						user_id: current_user.id,
					 						problem_id: @problem.id,
					 						submission: solution,
					 						correct: correct,
					 						points:	points)
	end

	private
		def competition_active
			start_time = Time.parse(Setting.find_by(name: 'start_time').value)
			end_time = Time.parse(Setting.find_by(name: 'end_time').value)

			unless (start_time < Time.zone.now && Time.zone.now < end_time)
				flash[:danger] = "The competition isn't active!"
				redirect_to root_url
			end
		end

		def belong_to_team
			unless current_user.team_id
				flash[:danger] = "You cannot solve problems unless you belong to a team!"
				redirect_to @problem
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
