class MessagesController < ApplicationController
  before_action :user_logged_in, only: [:index, :create]
  before_action :chat_enabled, only: [:index, :create]

  def index
    @messages = Message.all
    @message = Message.new
  end

  def create
    Message.create!(user_id: current_user.id,
                    priority: :info,
                    url: chat_path,
                    message: params[:message][:message])
    redirect_to chat_path
  end

  private
    def user_logged_in
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    def chat_enabled
      unless chat_enabled?
        flash[:danger] = "Access denied."
        redirect_to root_url
      end
    end
  
end