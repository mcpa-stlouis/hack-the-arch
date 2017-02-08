class ConsoleController < ApplicationController
  before_action :logged_in_user
  before_action :console_enabled

  def index
    $host = console_host  
  end

  private

    def console_enabled
      unless console_enabled?
        flash[:danger] = "Access denied."
        redirect_to root_url
      end
    end

end
