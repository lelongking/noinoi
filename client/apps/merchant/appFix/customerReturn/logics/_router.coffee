FlowRouter.route '/returnCustomer',
  name: 'returnCustomer'
  action: ->
    Session.set "currentAppInfo",
      name: "khách hàng trả hàng"

    BlazeLayout.render 'merchantLayout',
      content: 'customerReturn'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]
