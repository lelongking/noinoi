merchantRouter = Wings.Routers.merchantRouter
merchantRouter.route '/priceBook',
  name: 'priceBook'
  action: ->
    Session.set "currentAppInfo",
      name: "bảng giá"

    BlazeLayout.render 'merchantLayout',
      content: 'priceBook'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]
