class ProblemsController < ApplicationController
	before_action :logged_in_user
	before_action :admin_user, only: [:destroy, :create, :edit, :update, :new, :remove_hint, :add_hint]
	before_action :belong_to_team, only: [:index, :show]
	before_action :competition_active, only: [:index, :show]
	
	def index
		if current_user && current_user.admin?
			@problems = Problem.all.order!(category: 'ASC', points: 'ASC')
		else
			@problems = Problem.where(visible: true).order!(category: 'ASC', points: 'ASC')
		end

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
	end

	def create
		@problem = Problem.new(problem_params)
		if @problem.save
      redirect_to problems_url
		else
			render 'new'
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
	end

	def update
		@problem = Problem.find(params[:id])
		if @problem.update_attributes(problem_params)
			flash[:success] = "Changes saved successfully"
			redirect_to @problem
		else
			render 'edit'
		end
	end

	private
		def problem_params
			params.require(:problem).permit(:name, :category, :description, :points, :solution, :correct_message, :false_message, :picture, :visible, :solution_case_sensitive)
		end

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
				redirect_to current_user
			end
		end
		
		def admin_user
      unless current_user.admin?
				store_location
				flash[:danger] = "Access Denied."
				redirect_to root_url
			end
    end

		def competition_active
			unless current_user.admin? || competition_active?
				flash[:danger] = "The competition isn't active!"
				redirect_to root_url
			end
		end
end
