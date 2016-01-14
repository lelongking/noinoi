merchantRouter = Wings.Routers.merchantRouter
merchantRouter.route '/option',
  name: 'option'
  action: ->
    Session.set "currentAppInfo",
      name: "tuỳ chỉnh"

    BlazeLayout.render 'merchantLayout',
      content: 'merchantOptions'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]