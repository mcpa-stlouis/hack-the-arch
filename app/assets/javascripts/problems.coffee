# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
hints = ""

setup_hooks = ->
  if !document.getElementById('new_hint') 
    return

  $(document).on 'confirm:complete', (evt, answer) ->
    if evt.target.value == "Start VM" && answer
      evt.target.value = "Starting..."

  $('.filter').keyup ->
    rex = new RegExp($(this).val(), 'i')
    $('.searchable tr').hide()
    $('.searchable tr').filter(->
      rex.test $(this).text()
    ).show()
    return


  $(".hint_row").click ->
    $.post "/problems/add_hint", {
      "csrf-token": $('meta[name=csrf-token]').attr("content")
      "hint_id": $(this).data("hint-id")
      "problem_id": $(this).data("problem-id")
    }, (result) ->
      $(".new_hint_modal").modal("hide")
      location.reload()
      return
  return

setup_console = ->
  if !document.getElementById('drawer') 
    return

  # Update deadlines
  while typeof expiration == 'undefined'
    sleep(500)

  deadline = new Date(Date.parse(new Date) + (expiration * 1000))

  getTimeRemaining = (endtime) ->
    t = Date.parse(endtime) - Date.parse(new Date)
    seconds = Math.floor(t / 1000 % 60)
    minutes = Math.floor(t / 1000 / 60 % 60)
    hours = Math.floor(t / (1000 * 60 * 60) % 24)
    {
      'total': t
      'hours': hours
      'minutes': minutes
      'seconds': seconds
    }

  initializeClock = (id, endtime) ->
    clock = document.getElementById(id)
    hoursSpan = clock.querySelector('.hours')
    minutesSpan = clock.querySelector('.minutes')
    secondsSpan = clock.querySelector('.seconds')

    updateClock = ->
      t = getTimeRemaining(endtime)
      hoursSpan.innerHTML = ('0' + t.hours).slice(-2)
      minutesSpan.innerHTML = ('0' + t.minutes).slice(-2)
      secondsSpan.innerHTML = ('0' + t.seconds).slice(-2)
      if t.total <= 0
        clearInterval timeinterval
        clock.innerHTML = "This session has expired. Re-authenticate for a new one."
      return

    updateClock()
    timeinterval = setInterval(updateClock, 1000)
    return

  initializeClock 'expiration', deadline

  # Get the console URL
  check_url = ->
    $.ajax
      url: '/console_url'
      method: 'GET'
      accepts: text: 'application/json'
      statusCode:
        200: (data) ->
          $('#loader').remove()
          window.open(data.url, 'docker_term')
          $('#vnc_link').attr("href", data.vnc_link)
          $('#vnc_link').removeAttr("disabled")
          return
        102: ->
          setTimeout check_url, 1000
          return
    return

  check_url()
  return

$(document).on('turbolinks:load', setup_hooks)
$(document).on('turbolinks:load', setup_console)
