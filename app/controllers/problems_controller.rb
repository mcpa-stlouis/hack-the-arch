class ProblemsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, only: [:destroy, :create, :edit, :update, :new, :remove_hint, :add_hint]
  before_action :belong_to_team, only: [:index, :show]
  before_action :competition_active, only: [:index, :show]
  
  def index
    if current_user && current_user.admin?
      @problems = Problem.all.order!(category: 'ASC', points: 'ASC')
      @points_created = Problem.sum(:points)
    else
      @problems = Problem.where(visible: true)
        .order!(category: 'ASC', points: 'ASC')
        .select { |p| p.dependencies_solved_by_team?(current_team) }
    end
    @points_available = Problem.where(visible: true).sum(:points)

    if params[:problem_id]
      # If a specific problem was open, keep it open
      @problem_view = Problem.find(params[:problem_id])

      # If the hints tab was active, keep it active
      if session[:hint_requested]
        @hint_requested = true
        session.delete(:hint_requested)
      end
    end
  end

  def new
    @problem = Problem.new
    @available_dependencies = Problem.all
  end

  def create
    @problem = Problem.new(problem_params)
    @available_dependencies = Problem.all

    if params[:problem][:dependent_problems]
      dependencies = params[:problem][:dependent_problems].select {|p| p != ""}
      @problem.dependent_problems = Problem.where(id: dependencies)
    end

    if @problem.save
      redirect_to problems_url
    else
      render :new
    end
  end

  def show
    @problem = Problem.find(params[:id])
    if @problem.visible
      redirect_to controller: 'problems', action: 'index', anchor: "heading_#{(@problem.id-1).to_s}", problem_id: @problem.id
    else
      redirect_to problems_url
    end
  end

  def remove_hint
    # Hint implements reference counting (i.e., don't worry about it here)
    if (@problem = Problem.find(params[:problem_id])) && Hint.find(params[:hint_id])
      @problem.remove(params[:hint_id])
      flash[:success] = "Hint removed successfully"
      redirect_to @problem
    else
      flash[:error] = "Hint or Problem ID invalid"
      redirect_to problems_url
    end
  end

  def add_hint
    # Hint implements reference counting (i.e., don't worry about it here)
    if (@problem = Problem.find(params[:problem_id])) && Hint.find(params[:hint_id])
      @problem.add(params[:hint_id])
      flash[:success] = "Hint added successfully"
      render json: { status: :ok }
    else
      flash[:error] = "Hint or Problem ID invalid"
      redirect_to problems_url
    end
  end

  def destroy
    problem = Problem.find(params[:id])

    # Remove hints (to update ref counters)
    problem.remove_all_hints
    
    # Destroy problem
    problem.destroy
    flash[:success] = "Problem deleted"
    redirect_to problems_url
  end

  def edit
    @problem = Problem.find(params[:id])
    @available_dependencies = Problem.where.not(id: [@problem.id].concat(Problem.find_parents(@problem).pluck(:id)))
  end

  def update
    @problem = Problem.find(params[:id])

    if params[:problem][:dependent_problems]
      dependencies = params[:problem][:dependent_problems].select {|p| p != ""}
      @problem.dependent_problems.replace Problem.where(id: dependencies)
      @problem.save
    end

    if @problem.update_attributes(problem_params)
      flash[:success] = "Changes saved successfully"
      redirect_to @problem
    else
      render :edit
    end
  end

  private
    def problem_params
      params.require(:problem).permit(:name, :category, :description, :points, :solution, :correct_message, :false_message, :picture, :visible, :solution_case_sensitive, :dependent_problems)
    end

    def belong_to_team
      unless current_user.team_id
        flash[:danger] = "You must belong to a team to view the problems!"
        redirect_to current_user
      end
    end
end
