Enums = Apps.Merchant.Enums
scope = logics.sales

Wings.defineApp 'login_v01',
  created: ->
    Session.set('loginValid', 'invalid')
  rendered: ->
    $("body").css("overflow-y", "scroll")

  destroyed: ->
    $("body").css("overflow-y", "hidden")
    Session.set('loginValid')

#  helpers:
  events:
    "click #authButton.valid": (event, template) ->
      console.log 'click'
      logics.homeHeader.login(event, template)

    "input .login-field": (event, template) ->
      $login    = $(template.find("#authAlias"))
      $password = $(template.find("#authSecret"))
      console.log $login.val(), $password.val()
      if $login.val().length > 0 and $password.val().length > 0 and $login.val().indexOf('@') isnt -1
        Session.set('loginValid', 'valid')
      else
        Session.set('loginValid', 'invalid')

    "keypress .login-field": (event, template) ->
      $(template.find("#authButton")).click() if event.which is 13 and Session.get('loginValid') is 'valid'