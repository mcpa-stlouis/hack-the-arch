# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

init = ->
  if !document.getElementById('filter') 
    return
  
  $('.filter').keyup ->
    rex = new RegExp($(this).val(), 'i')
    $(".filter_list > li").each ->
      $(this).hide()
      $(this).filter(->
        rex.test $(this).text()
      ).show()
    return
  return

$(document).on('turbolinks:load', init)
