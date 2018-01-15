class ScoreboardController < ApplicationController
  before_action :competition_started

  def index
    @scoreboard_on = scoreboard_on?
    # reject admins
    @teams = Team.where.not(name: 'admins')
    @brackets = Bracket.all.order(priority: :asc)
    @sorted_teams = @teams.sort_by { |team| [-team.get_score, team.get_most_recent_solve_datetime] }
    @points_available = Problem.where(visible: true).sum(:points)
  end

  def get_score_data
    @scores = Team.get_top_teams_score_progression
    render :json => { teams: @scores['teams'].to_json.html_safe, 
                      scores: @scores['scores'].to_json.html_safe, 
                      status: :ok}
  end

end
