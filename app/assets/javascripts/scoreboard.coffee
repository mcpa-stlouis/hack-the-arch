# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

draw_scoreboard = ->
  if !document.getElementById('scoreboard_graph')
    return

  $.get 'teams/get_score_data', (response,status) ->

    if typeof document.chart == "undefined"
      document.chart = c3.generate
        bindto: '#scoreboard_graph'
        data:
          xs: JSON.parse(response.teams)
          columns: JSON.parse(response.scores)
          type: 'step'
        axis:
          x: tick:
            count: 10
            format: (x) ->
              moment(x * 1000).local().format 'LLL'
          y: label: text: 'Score'
        zoom: enabled: true
    else
      document.chart.load
        xs: JSON.parse(response.teams)
        columns: JSON.parse(response.scores)
    setTimeout draw_scoreboard, 30000

    return
  return

$(document).on('turbolinks:load', draw_scoreboard)
