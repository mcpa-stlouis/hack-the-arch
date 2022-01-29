class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast('message_channel', { message: render_message(message),
                                                    sender: (message.user.admin?) ? "admin" : message.user.username,
                                                    text: message.message,
                                                    url: message.url,
                                                    priority: message.priority })
  end

  private
    def render_message(message)
      ApplicationController.renderer.render(partial: 'messages/message',
                                             locals: { message: message })
    end
end
