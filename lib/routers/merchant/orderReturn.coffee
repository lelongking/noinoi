merchantOrderReturnRouter = Wings.Routers.merchantOrderReturnRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/orderReturn'
    name: "orderReturnRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]


merchantOrderReturnRouter.route '/',
  name: 'orderReturn'
  action: ->
    Session.set "currentAppInfo",
      name: "trả hàng bán"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      container: 'orderReturnLayout'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /order trigger'
    return
  ]