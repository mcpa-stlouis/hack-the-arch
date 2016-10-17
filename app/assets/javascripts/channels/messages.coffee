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
    if data.sender is 'admin' # and document.location.pathname is not '/chat'
      msg = "<div style='display:none' class='alert fade in alert-#{data.priority}'> \
               <button type='button' class='close' data-dismiss='alert' aria-label='Close'> \
            <span aria-hidden='true'>&times;</span> \
          </button> \
          #{data.text} \
        </div>"
      $(msg).appendTo('#notifications').show()
      setTimeout checkAlert, 10000
