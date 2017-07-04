class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  include SettingsHelper

  protected

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

    def competition_active
      unless current_user.admin? || competition_active?
        flash[:danger] = "The competition isn't active!"
        redirect_to root_url
      end
    end

    def competition_started
      unless (current_user && current_user.admin?) || competition_started?
        flash[:danger] = "The competition hasn't started!"
        redirect_to root_url
      end
    end

end
