class HintsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, only: [:new, :create, :edit, :update]

  def new
    @hint = Hint.new
    @problem = Problem.find(params[:problem_id])
  end

  def create
    @hint = Hint.new(hint_params)
    @problem = Problem.find(params[:hint][:problem_id])
    if @hint.save
      @problem.add(@hint.id)
      flash[:success] = "Hint saved!"
      redirect_to @problem
    else
      render 'new'
    end
  end

  def edit
    @hint = Hint.find(params[:id])
    @problem = Problem.find(params[:problem_id])
  end

  def update
    @hint = Hint.find(params[:id])
    if @hint.update(hint_params)
      @problem = Problem.find(params[:hint][:problem_id])
      redirect_to @problem
    else
      render 'edit'
    end
  end

  private
    def hint_params
      params.require(:hint).permit(:priority, :hint, :points)
    end
end
