class SessionsController < ApplicationController
  def new
  end

	def create
		user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page.
			flash[:success] = "Welcome to HackTheArch!"
			log_in user 
			params[:session][:remember_me] == '1' ? remember(user) : forget(user)
			redirect_back_or user
    else
      # Create an error message.
			flash.now[:danger] = "Invalid email or password"
      render 'new'
    end
	end

	def destroy
		log_out if logged_in?
		redirect_to root_url
	end
end
