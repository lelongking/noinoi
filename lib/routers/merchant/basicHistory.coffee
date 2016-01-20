merchantRouter = Wings.Routers.merchantRouter

merchantRouter.route '/basicHistory',
  name: 'basicHistory'
  action: ->
    Session.set "currentAppInfo",
      name: "báo cáo"
      navigationPartial:
        template: "basicHistoryNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'basicHistory'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]



