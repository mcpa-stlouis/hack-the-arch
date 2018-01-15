class HintRequestsController < ApplicationController
  before_action :logged_in_user, only: :create
  before_action :belong_to_team, only: :create
  before_action :competition_active, only: :create

  def create
    points = 0
    @problem = Problem.find(params[:problem_id])
    @bracket = Bracket.find(current_team.bracket_id)
    @user = current_user

    @team = Team.find(@user.team_id)
    hints_requested = @team.get_hints_requested(@problem.id).count

    if @problem.solved_by?(@team.id)
      flash[:warning] = "Your team has already solved this challenge!"

    elsif hints_requested >= @problem.number_of_hints_available ||
          @problem.number_of_hints_available <= 0 
      flash[:warning] = "No more hints available!"

    elsif use_handicap? && hints_requested >= @bracket.hints_available
      flash[:warning] = "No more hints for your bracket!"

    else
      @hint = Hint.find(@problem.get_next_hint(@team.id, @problem.id))


      HintRequest.create(team_id:  @user.team_id,
                         user_id: @user.id,
                         problem_id: @problem.id,
                         hint_id: @hint.id,
                         points:  @hint.points)
    end

    session[:hint_requested] = true # Used to activate hint tab on page load
    redirect_to @problem
  end

  private

    def belong_to_team
      unless current_user.team_id
        flash[:danger] = "You must belong to a team to request hints!"
        redirect_to root_url
      end
    end
end
