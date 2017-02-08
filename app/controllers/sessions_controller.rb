class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated? && user.paid? && (!admin_account_auth? || user.authorized?)
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else

        if !user.paid?
          flash[:warning] = 'Please finish checking out to complete your registration!'
          redirect_to checkout_path(user)
        elsif (admin_account_auth? && !user.authorized?)
          message  = 'Account not authorized '
          message += 'Please allow additional time for an administrator to authorized your account.'
          flash[:warning] = message
          redirect_to root_url
        else
          message  = 'Account not activated. '
          message += 'Check your email for the activation link.'
          flash[:warning] = message
          redirect_to root_url
        end

      end
    else
      # Create an error message.
      flash.now[:danger] = 'Invalid email or password'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
