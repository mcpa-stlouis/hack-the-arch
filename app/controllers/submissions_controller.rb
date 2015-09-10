class SubmissionsController < ApplicationController

	def new
	end

	def create
		correct = false
		points = 0
		solution = params[:submission][:value]
		@problem = Problem.find(params[:submission][:id])

		if current_user.team_id

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
		else
			flash[:danger] = "You cannot solve problems unless you belong to a team!"
			redirect_to @problem
		end

	end

end
