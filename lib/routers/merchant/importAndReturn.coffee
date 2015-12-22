merchantRouter = Wings.Routers.merchantRouter
merchantRouter.route '/import',
  name: 'import'
  action: ->
    Session.set "currentAppInfo",
      name: "nhập kho"

    BlazeLayout.render 'merchantLayout',
      content: 'import'
    return

  triggersEnter: [ (context, redirect) ->
    merchantRouter.go('/merchant') unless User.hasManagerRoles()
    console.log 'running /import trigger'
    return
  ]



merchantRouter.route '/returnProvider',
  name: 'returnProvider'
  action: ->
    Session.set "currentAppInfo",
      name: "trả hàng NCC"

    BlazeLayout.render 'merchantLayout',
      content: 'providerReturn'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]
