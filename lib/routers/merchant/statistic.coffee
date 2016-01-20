merchantRouter = Wings.Routers.merchantRouter
merchantRouter.route '/statistic',
  name: 'statistic'
  action: ->
    Session.set "currentAppInfo",
      name: "thống kê"

    BlazeLayout.render 'merchantLayout',
      content: 'statisticLayout'
    return

  triggersEnter: [ (context, redirect) ->
    return
  ]
