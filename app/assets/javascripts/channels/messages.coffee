App.messages = App.cable.subscriptions.create "MessagesChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->

    # Add new message to chat window
    $(data.message).hide().appendTo('#message_list').slideDown ->
      $("#messages").animate({scrollTop: $('#messages').prop("scrollHeight")}, "fast")

    # If user isn't on chat window create notification
    if data.sender is 'admin'  and document.location.pathname != '/chat'
      $.notify { message: "#{data.text}", url: "#{data.url}", target: '_self' },
        type: "#{data.priority}", mouse_over: 'pause', offset: y: 60
      return
