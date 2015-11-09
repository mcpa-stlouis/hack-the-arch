class BracketsController < ApplicationController
	before_action :logged_in_user
	before_action :admin_user

	def new
		@bracket = Bracket.new
	end

	def create
		@bracket = Bracket.new(bracket_params)
		if @bracket.save
      flash[:success] = "Bracket created!"
      redirect_to admin_url
		else
			render 'new'
		end
	end

	def edit
		@bracket = Bracket.find(params[:id])
	end

	def update
		@bracket = Bracket.find(params[:id])
		if @bracket.update_attributes(bracket_params)
			flash[:success] = "Changes saved successfully"
			redirect_to admin_url
		else
			render 'edit'
		end
	end

	def destroy
		Bracket.find(params[:id]).destroy
    flash[:success] = "Bracket deleted"
    redirect_to admin_url
	end

	private
		def bracket_params
			params.require(:bracket).permit(:name, :priority, :hints_available)
		end

		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end

		def admin_user
      unless current_user.admin?
				flash[:danger] = "Access denied."
				redirect_to root_url
			end
    end

end
