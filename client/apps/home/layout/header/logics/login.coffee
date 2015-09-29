logics.homeHeader.login = (event, template) ->
  $login    = $(template.find("#authAlias"))
  $password = $(template.find("#authSecret"))
  $.cookie('lastAuthAlias', $login.val())

  Meteor.loginWithPassword $login.val(), $password.val(), (error) ->
    currentReason = error?.reason

    (FlowRouter.go('/merchant'); return) if !error

    for currentLoginError in logics.homeHeader.loginErrors
      if currentLoginError.reason is currentReason
        if currentLoginError.isPasswordError
          $password.notify(i18n(currentLoginError.message), {position: "bottom right"})
        else
          $login.notify(i18n(currentLoginError.message), {position: "bottom left"})
        Session.set('loginValid', 'invalid')