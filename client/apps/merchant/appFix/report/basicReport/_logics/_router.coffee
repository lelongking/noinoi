FlowRouter.route '/basicReport',
  name: 'basicReport'
  action: ->
    Session.set "currentAppInfo",
      name: "báo cáo"

    BlazeLayout.render 'merchantLayout',
      content: 'basicReport'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /basicReport trigger'
    return
  ]