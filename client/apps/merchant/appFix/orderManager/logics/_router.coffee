FlowRouter.route '/orderManager',
  name: 'orderManager'
  action: ->
    Session.set "currentAppInfo",
      name: "đơn hàng"

    BlazeLayout.render 'merchantLayout',
      content: 'orderManager'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]
