FlowRouter.route '/basicHistory',
  name: 'basicHistory'
  action: ->
    Session.set "currentAppInfo",
      name: "báo cáo"

    BlazeLayout.render 'merchantLayout',
      content: 'basicHistory'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]