# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
draw_switches = ->
  if document.getElementById('settings') 
    $(".bootstrap-switches").bootstrapSwitch()
    return

search_toggle = ->
  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    if e.target.hash == '#teams' || e.target.hash == '#users'
      $("#filter_container").show()
    else
      $("#filter_container").hide()

$(document).on('page:change', draw_switches)
$(document).on('page:change', search_toggle)
