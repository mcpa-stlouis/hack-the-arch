class ProblemsController < ApplicationController
	before_action :logged_in_user, only: [:index, :show]
	before_action :admin_user, only: [:destroy, :create, :edit, :update, :new]
	
	def index
		@problems = Problem.paginate(page: params[:page])
	end

	def show
		@problem = Problem.find(params[:id])
		@user = current_user
		if !@user.team_id
			flash[:danger] = "You can't view the problems unless you have joined a team!"
			redirect_to problems_url
		else
			@team = Team.find(@user.team_id)
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

	def destroy
    Problem.find(params[:id]).destroy
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
			params.require(:problem).permit(:name, :category, :description, :points, :solution, :correct_message, :false_message)
		end

		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end
		
		def admin_user
      unless logged_in? && current_user.admin?
				store_location
				flash[:danger] = "Access Denied."
				redirect_to root_url
			end
    end
end
