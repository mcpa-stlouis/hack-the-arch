class SubmissionsController < ApplicationController
  before_action :logged_in_user, only: [:index, :create, :new]
  before_action :belong_to_team, only: [:create, :new]
  before_action :competition_active, only: [:create, :new]
  before_action :admin_user, only: [:index]

  rescue_from 'ActionView::Template::Error' do |e|
    redirect_to controller: :submissions, action: :index, search: 'Invalid Regix'
  end

  def index
    @submissions = if params[:search]
      Submission.joins(:problem, :user, :team)
                .where('problems.name SIMILAR TO :q OR ' \
                       'users.username SIMILAR TO :q OR ' \
                       'teams.name SIMILAR TO :q OR ' \
                       'submission SIMILAR TO :q',
                  q: "%#{params[:search]}%")
                .reorder(id: :desc).page(params[:page]).per_page(100)
    else
      Submission.reorder(id: :desc).page(params[:page]).per_page(100)
    end
  end

  def new
  end

  def create
    correct = false
    points = 0
    user_solution = params[:submission][:value]
    @problem = Problem.find(params[:submission][:id])

    # If the dependent problems haven't been solved
    unless (@problem.dependencies_solved_by_team?(current_team) || @problem.visible)
      flash[:warning] = "Access Denied"
      redirect_to problems_path
      return
    end

    # If the user is trying to brute force
    unless (!current_user.last_submission || (current_user.last_submission + 15.seconds) < DateTime.now)
      flash[:warning] = "Slow down!  You can only attempt to answer once every fifteen seconds!"
      redirect_to @problem
      return
    end

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
    elsif (!@problem.solution_regex? and user_solution == correct_solution) or
          (@problem.solution_regex? and /#{correct_solution}/.match(user_solution))
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

    current_user.update(last_submission: DateTime.now)
    Submission.create(team_id:  current_user.team_id,
                      user_id: current_user.id,
                      problem_id: @problem.id,
                      submission: user_solution,
                      correct: correct,
                      points: points)

    if correct and scoring_notifications?
      Message.create(user_id: User.where(admin: true).first.id,
                     priority: :success,
                     url: scoreboard_path,
                     message: "#{current_user.username} just scored " +
                              "#{points} points for " +
                              "#{current_user.team.name}!")
    end

  end

  private
    def belong_to_team
      unless current_user.team_id
        flash[:danger] = "You cannot solve problems unless you belong to a team!"
        redirect_to @problem
      end
    end

end
