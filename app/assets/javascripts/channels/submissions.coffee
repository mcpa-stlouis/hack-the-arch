App.submissions = App.cable.subscriptions.create "SubmissionsChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    url = new URL(document.location)

    page = url.searchParams.get('page')
    search = url.searchParams.get('search')

    if !page or page == '1' or $(data.submission).match('/'+search+'/').length > 0
      $(data.submission).hide().prependTo('#submissions').slideDown()
