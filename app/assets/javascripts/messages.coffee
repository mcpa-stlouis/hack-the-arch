# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

scroll_to_bottom = ->
  if !document.getElementById('messages') 
    return

  $("#messages").scrollTop -> return this.scrollHeight
  $("#message_message").focus()
  return

$(document).on('turbolinks:load', scroll_to_bottom)
