class ProblemsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, only: [:destroy, :create, :edit, :update, :new, :remove_hint, :add_hint]
  before_action :belong_to_team, only: [:index, :show]
  before_action :competition_active, only: [:index, :show]
  
  def index

    # Page-wide variables
    @points_available = Problem.where(visible: true).sum(:points)
    @expiration = current_user.stack_expiry
    @active_stack = (!@expiration.nil? && @expiration > DateTime.now())
    if @active_stack
      @expire_seconds = (@expiration - DateTime.now()).to_i 
    end

    # Get problems
    if current_user && current_user.admin?
      @problems = Problem.all.order!(category: 'ASC', points: 'ASC', name: 'ASC')
      @points_created = Problem.sum(:points)
      @is_admin = true
    else
      @problems = Problem.where(visible: true)
        .order!(category: 'ASC', points: 'ASC')
        .select { |p| p.dependencies_solved_by_team?(current_team) }
    end

    # Open problem if it was passed
    if params[:problem_id]
      # If a specific problem was open, keep it open
      @problem_view = Problem.find(params[:problem_id])

      # If the hints tab was active, try to keep it active
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

    if @problem.update(problem_params)
      flash[:success] = "Changes saved successfully"
      redirect_to @problem
    else
      render :edit
    end
  end

  def console_url
    unless current_user.container_id.nil? or current_user.container_id.empty?
      @console_host = ENV.fetch("CONSOLE_HOST") { "http://127.0.0.1:8888" }
      @hash = Digest::SHA1.hexdigest(
        "#{current_user.id}#{current_user.container_id}"
      )
      @params = CGI.escape(Base64.strict_encode64(
        "#{@hash},#{current_user.problem_id},#{current_user.id}"
      ))
      @status = :ok
      @render = { url: "#{@console_host}/?q=#{@params}",
                  vnc_link: "#{@console_host}/vnc.html?q=#{@params}" }
    else
      @status = :processing
      @render = { error: 'Container not ready yet...' }

    end
    respond_to do |format|
      format.json { render json: @render.to_json, status: @status }
    end
  end

  def start_stack
    if swarm_services_enabled?
      @problem = Problem.find(params[:id])

      if @problem.stack.empty? or @problem.network.empty?
        flash[:danger] = "No stack or network defined for that challenge!"
        redirect_to @problem
        return
      end

      lifespan = 30
      challenge = Hash.new(0)
      challenge["user_id"] = current_user.id
      challenge["problem_id"] = @problem.id
      challenge["network"] = @problem.network
      challenge["services"] = @problem.stack
      challenge["lifespan"] = lifespan.to_s

      DestroyStackJob.set(wait: lifespan.minutes)
                               .perform_later(challenge)
      CreateStackJob.perform_now challenge

      redirect_to @problem
    else
      flash[:danger] = "Unauthorized"
      redirect_to @problem
    end
  end

  private
    def problem_params
      params.require(:problem).permit(:name, :category, :description, :points, :solution, :correct_message, :false_message, :picture, :visible, :solution_case_sensitive, :solution_regex, :dependent_problems, :network, :stack, :vnc)
    end

    def belong_to_team
      unless current_user.team_id
        flash[:danger] = "You must belong to a team to view the problems!"
        redirect_to current_user
      end
    end
end
