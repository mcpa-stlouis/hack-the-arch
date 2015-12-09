# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
accuracy_data = ""
category_data = ""

init = ->
  if !document.getElementById('filter') 
    return
  
  $('#filter').keyup ->
    rex = new RegExp($(this).val(), 'i')
    $(".users_list > li").each ->
      $(this).hide()
      $(this).filter(->
        rex.test $(this).text()
      ).show()
    return
  return

draw_graphs = ->
  if !document.getElementById('user_accuracy') 
    return

  $.get 'get_stats', {id: user_id}, (response,status) ->
    accuracy_data = JSON.parse(response.accuracy_data)
    category_data = JSON.parse(response.category_data)
    finish_drawing_graphs()
    return
  return

finish_drawing_graphs = ->
  accuracy_chart = c3.generate
    bindto: '#user_accuracy'
    data:
      columns: accuracy_data
      type: 'donut'
    donut:
      title: 'Accuracy'
    color:
      pattern: ['#009900', '#990000']
  category_chart = c3.generate
    bindto: '#user_categories'
    data:
      columns: category_data
      type: 'donut'
    donut:
      title: 'Category'
  return

$(document).on('page:change', draw_graphs)
$(document).on('page:change', init)
