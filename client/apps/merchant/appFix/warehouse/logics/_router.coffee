FlowRouter.route '/warehouse',
  name: 'warehouse'
  action: ->
    Session.set "currentAppInfo",
      name: "quản lý kho hàng"
      navigationPartial:
        template: "warehouseNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'warehouse'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]
