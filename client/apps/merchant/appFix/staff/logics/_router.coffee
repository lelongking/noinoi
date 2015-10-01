FlowRouter.route '/staff',
  name: 'staff'
  action: ->
    Session.set "currentAppInfo",
      name: "nhân viên"

    BlazeLayout.render 'merchantLayout',
      content: 'staffManagement'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]