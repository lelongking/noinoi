FlowRouter.route '/billDetail',
  name: 'billDetail'
  action: ->
    Session.set "currentAppInfo",
      name: "chi tiết phiếu bán"

    BlazeLayout.render 'merchantLayout',
      content: 'billDetail'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]