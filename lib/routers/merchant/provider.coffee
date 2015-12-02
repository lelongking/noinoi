merchantRouter = Wings.Routers.merchantRouter

merchantRouter.route '/provider',
  name: 'provider'
  action: ->
    Session.set "currentAppInfo",
      name: "nhà cung cấp"
      navigationPartial:
        template: "providerManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'providerManagement'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]