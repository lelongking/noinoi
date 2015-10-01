FlowRouter.route '/import',
  name: 'import'
  action: ->
    Session.set "currentAppInfo",
      name: "nhập kho"

    BlazeLayout.render 'merchantLayout',
      content: 'import'
    return

  triggersEnter: [ (context, redirect) ->
    FlowRouter.go('/merchant') unless User.hasManagerRoles()
    console.log 'running /provider trigger'
    return
  ]
