sockjs = window.sockjs

log = (m) ->
  $('#output').append($("<code>").text(m))
  $('#output').append($("<br>"))
  $('#output').scrollTop($('#output').scrollTop()+10000)

sockjs_url = '/echo'
sockjs = new SockJS(sockjs_url)
sockjs.onopen = ->
  log(' [*] Connected (using: '+sockjs.protocol+')')
sockjs.onclose = (e) ->
  log(' [*] Disconnected ('+e.status + ' ' + e.reason+ ')')
sockjs.onmessage = (e) ->
  log(' [ ] received: ' + JSON.stringify(e.data))

'''
setInterval( () -> 
  if not sockjs.readyState == SockJS.OPEN
    l += ' (error, connection not established)'
  else
    console.log(5)
    sockjs.send({a:5})
1000)'''

$('#input').focus()
$('#form').submit(() ->
  val = $('#input').val()
  $('#input').val('')
  l = ' [ ] sending: ' + JSON.stringify(val)
  if not sockjs.readyState == SockJS.OPEN
    l += ' (error, connection not established)'
  else
    console.log(val)
    sockjs.send(val)
  log(l)
  return false)
