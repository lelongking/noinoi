merchantRouter = Wings.Routers.merchantRouter

merchantRouter.route '/staff',
  name: 'staff'
  action: ->
    Session.set "currentAppInfo",
      name: "nhân viên"

    BlazeLayout.render 'merchantLayout',
      content: 'staffManagement'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]



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