class ConsoleController < ApplicationController
  before_action :user_logged_in, only: [:index, :create]
  before_action :console_enabled, only: [:index, :create]

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
