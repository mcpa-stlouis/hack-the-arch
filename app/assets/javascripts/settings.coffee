# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
search_toggle = ->
  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    if e.target.hash == '#teams' || e.target.hash == '#users'
      $("#filter_container").show()
    else
      $("#filter_container").hide()

$(document).on('turbolinks:load', search_toggle)
