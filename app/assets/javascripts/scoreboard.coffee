# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
column_data = ""
xs_data = ""

draw_scoreboard = ->
  if !document.getElementById('scoreboard_graph') 
    return

  $.get 'teams/get_score_data', (response,status) ->
    column_data = JSON.parse(response.scores)
    xs_data = JSON.parse(response.teams)
    finish_drawing_scoreboard()
    return
  return

finish_drawing_scoreboard = ->
  chart = c3.generate
    bindto: '#scoreboard_graph'
    data:
      xs: xs_data
      columns: column_data
      type: 'step'
    axis:
      x: tick:
        count: 10
        format: (x) ->
          moment(x * 1000).local().format 'LLL'
      y: label: text: 'Score'
    zoom: enabled: true
  setTimeout draw_scoreboard, 30000
  return

$(document).on('page:change', draw_scoreboard)
