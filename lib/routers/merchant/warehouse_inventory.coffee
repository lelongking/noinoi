merchantWarehouseRouter = Wings.Routers.merchantWarehouseRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/warehouse'
    name: "warehouseRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]

merchantWarehouseRouter.route '/',
  name: 'warehouse'
  action: ->
    Session.set "currentAppInfo",
      name: "quản lý kho"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      container: 'warehouseLayout'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]