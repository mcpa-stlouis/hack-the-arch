class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    @chat_path = Rails.application.routes.url_helpers.chat_path()
    ActionCable.server.broadcast 'message_channel', message: render_message(message),
                                                    sender: message.user.username,
                                                    text: message.message,
                                                    url: @chat_path,
                                                    priority: message.priority
  end

  private
    def render_message(message)
      ApplicationController.renderer.render(partial: 'messages/message',
                                             locals: { message: message })
    end
end
