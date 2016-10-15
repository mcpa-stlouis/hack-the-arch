App.submissions = App.cable.subscriptions.create "SubmissionsChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $(data.submission).hide().prependTo('#submissions').slideDown()
    $('.filter').keyup() # Call the filter function
