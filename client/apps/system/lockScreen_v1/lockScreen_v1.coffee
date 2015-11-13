setTime = -> Session.set('realtime-now', new Date())
Wings.defineApp 'lockScreen_v1',
  created: ->
    @timeInterval = Meteor.setInterval(setTime, 1000)
  rendered: ->
    $("body").addClass("lock-screen")
  destroyed: ->
    Meteor.clearInterval(@timeInterval)

#  helpers:


  events:
    "click .logOut": (event, template) -> Wings.logout()
    "click .btn-lock": (event, template) -> checkPassword(event, template)
    "keypress input.lock-input": (event, template) ->  checkPassword(event, template) if event.which is 13


checkPassword = (event, template)->
  $password = $(template.find(".lock-input"))
  Meteor.call 'checkPassword', Package.sha.SHA256($password.val()), (error, result) ->
    if error
      $(template.find(".form-group")).notify('mật khẩu không đúng', {position: "bottom left"})