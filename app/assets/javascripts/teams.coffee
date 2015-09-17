# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
team_names = ""
score_data_rows = ""

draw_scoreboard = ->
  $.get 'teams/get_score_data', (response,status) ->
    team_names = JSON.parse(response.teams)
    score_data_rows = JSON.parse(response.scores)
    finish_drawing_scoreboard()
    return
  return

finish_drawing_scoreboard = ->
  data = new (google.visualization.DataTable)
  data.addColumn 'string', 'Date'

  i = 0
  while i < team_names.length
    data.addColumn 'number', team_names[i]
    i++
  j = 0
  while j < score_data_rows.length
    score_data_rows[j][0] = String(Date(score_data_rows[j][0]))
    j++

  data.addRows score_data_rows
  chart = new (google.visualization.SteppedAreaChart)(document.getElementById('scoreboard_graph'))
  options = 
    areaOpacity: 0
    hAxis: textPosition: 'none'
    aggregationTarget: 'series'
    legend:
      position: 'top'
      alignment: 'center'
  chart.draw data, options
  return

google.load 'visualization', '1', 'packages': [ 'annotationchart' ]
google.setOnLoadCallback draw_scoreboard

$(document).ready(draw_scoreboard)
$(document).on('page:load', draw_scoreboard)
