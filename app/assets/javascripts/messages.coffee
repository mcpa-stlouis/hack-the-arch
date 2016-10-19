# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

scroll_to_bottom = ->
  if !document.getElementById('messages') 
    return


  options = 
    placement: (context, source) ->
      position = $(source).position()
      if window.innerWidth < 800
        return 'bottom'
      'left'
  $('[data-toggle="tooltip"]').tooltip options

  $("#messages").scrollTop -> return this.scrollHeight
  $("#message_message").focus()
  return

$(document).on('turbolinks:load', scroll_to_bottom)
