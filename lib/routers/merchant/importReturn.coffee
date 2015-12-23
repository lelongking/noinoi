merchantImportReturnRouter = Wings.Routers.merchantImportReturnRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/importReturn'
    name: "importReturnRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]


merchantImportReturnRouter.route '/',
  name: 'importReturn'
  action: ->
    Session.set "currentAppInfo",
      name: "trả hàng nhập"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      container: 'importReturnLayout'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /import trigger'
    return
  ]