merchantOrderRouter = Wings.Routers.merchantOrderRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/order'
    name: "orderRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]


merchantOrderRouter.route '/',
  name: 'order'
  action: ->
    Session.set "currentAppInfo",
      name: "bán hàng"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      container: 'orderLayout'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /order trigger'
    return
  ]