class SubmissionsController < ApplicationController
  before_action :user_logged_in, only: [:create, :new]
  before_action :belong_to_team, only: [:index]
  before_action :competition_active, only: [:create, :new]

  def new
  end

  def create
    correct = false
    points = 0
    user_solution = params[:submission][:value]
    @problem = Problem.find(params[:submission][:id])
    correct_solution = @problem.solution

    # If the solution is not case sensitive
    if (!@problem.solution_case_sensitive?)
      user_solution.upcase!
      correct_solution.upcase!
    end

    # If limit has been reached
    if (max = max_submissions_per_team) > 0 &&
        current_team.submissions.where(problem: @problem).count >= max
      flash[:warning] = "Your team has alread used the maximum number of guesses for this problem!"
      redirect_to @problem
      return

    # If the solution is correct
    elsif user_solution == correct_solution
      correct = true

      # And it has not already been solved
      if @problem.solved_by?(current_user.team_id)
        flash[:warning] = "Your team has already solved this!"
        redirect_to @problem
      else
        flash[:success] = @problem.correct_message
        points = @problem.points
        redirect_to @problem
      end

    # Or the answer has already been guessed
    elsif @problem.solved_by?(current_user.team_id)
      flash[:warning] = "Your team has already guessed that!"
      redirect_to @problem

    else
      flash[:danger] = @problem.false_message
      redirect_to @problem
    end
    Submission.create(team_id:  current_user.team_id,
                      user_id: current_user.id,
                      problem_id: @problem.id,
                      submission: user_solution,
                      correct: correct,
                      points: points)
  end

  private
    def competition_active
      unless competition_active?
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

    def user_logged_in
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end


end
