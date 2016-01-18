scope = logics.merchantOptions

Wings.defineHyper 'merchantAccountChangePassword',
  helpers:
    profile: -> Session.get("myProfile")
    showChangePasswordCommand: -> Session.get("merchantAccountOptionChangePasswordCommand")

  rendered: ->


  events:
    "input .accountChangePassword": (event, template) -> logics.merchantOptions.checkAccountChangePassword(template)
    "keyup .accountChangePassword": (event, template) -> logics.merchantOptions.updateAccountOptionChangePassword(template) if event.which is 13
    "click .changeAccountProfilePassword": (event, template) -> logics.merchantOptions.updateAccountOptionChangePassword(template)


