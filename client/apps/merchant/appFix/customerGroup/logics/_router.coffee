FlowRouter.route '/customerGroup',
  name: 'customerGroup'
  action: ->
    Session.set "currentAppInfo",
      name: "nhóm khách hàng"

    BlazeLayout.render 'merchantLayout',
      content: 'customerGroup'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]
