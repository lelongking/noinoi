merchantRouter = Wings.Routers.merchantRouter


merchantRouter.route '/transaction',
  name: 'transaction'
  action: ->
    Session.set "currentAppInfo",
      name: "thu chi"
      navigationPartial:
        template: "transactionNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'transaction'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]
