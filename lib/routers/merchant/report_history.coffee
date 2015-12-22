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


merchantRouter.route '/basicReport',
  name: 'basicReport'
  action: ->
    Session.set "currentAppInfo",
      name: "báo cáo"

    BlazeLayout.render 'merchantLayout',
      content: 'basicReport'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /basicReport trigger'
    return
  ]


