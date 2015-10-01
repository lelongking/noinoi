FlowRouter.route '/billManager',
  name: 'billManager'
  action: ->
    Session.set "currentAppInfo",
      name: "tình trạng phiếu bán"

    BlazeLayout.render 'merchantLayout',
      content: 'billManager'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]