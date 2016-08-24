class ScoreboardController < ApplicationController
	before_action :competition_started

	def index
		@scoreboard_on = scoreboard_on?
		# reject admins
		@teams = Team.where.not(name: 'admins')
		@brackets = Bracket.all
		@sorted_teams = @teams.sort_by { |team| [-team.get_score, team.get_most_recent_solve_datetime] }
	end

	def get_score_data
		@scores = Team.get_top_teams_score_progression
		render :json => { teams: @scores['teams'].to_json.html_safe, 
											scores: @scores['scores'].to_json.html_safe, 
											status: :ok}
	end

	private
		def competition_started
			unless (current_user && current_user.admin?) || competition_started?
				flash[:danger] = "The competition hasn't started!"
				redirect_to root_url
			end
		end

end
