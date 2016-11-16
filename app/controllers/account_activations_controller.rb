class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])

      user.activate

      message = "Account activated! "
      if admin_account_auth?
        message += "Please allow additional time for your account to be authorized by an administrator."
        flash[:warning] = message
        redirect_to root_url
      else
        log_in user
        flash[:success] = message
        redirect_to user
      end

    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end

end
