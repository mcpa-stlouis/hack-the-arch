# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
draw_switches = ->
  if document.getElementById('settings') 
    $(".bootstrap-switches").bootstrapSwitch()
		return

$(document).ready(draw_switches)
