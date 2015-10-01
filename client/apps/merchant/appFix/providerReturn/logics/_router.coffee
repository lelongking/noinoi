FlowRouter.route '/returnProvider',
  name: 'returnProvider'
  action: ->
    Session.set "currentAppInfo",
      name: "trả hàng NCC"

    BlazeLayout.render 'merchantLayout',
      content: 'providerReturn'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]