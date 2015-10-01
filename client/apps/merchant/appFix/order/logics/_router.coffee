FlowRouter.route '/order',
  name: 'order'
  action: ->
    Session.set "currentAppInfo",
      name: "bán hàng"

    BlazeLayout.render 'merchantLayout',
      content: 'order'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]
