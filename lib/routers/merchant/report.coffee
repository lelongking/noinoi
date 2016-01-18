merchantReportRouter = Wings.Routers.merchantReportRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/report'
    name: "reportRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]

merchantReportRouter.route '/',
  name: 'report'
  action: ->
    Session.set "currentAppInfo",
      name: "báo cáo"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      container: 'reportLayout'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /report trigger'
    return
  ]