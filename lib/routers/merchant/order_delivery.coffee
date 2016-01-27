merchantOrderRouter = Wings.Routers.merchantOrderRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/order'
    name: "orderRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]


merchantOrderRouter.route '/',
  name: 'order'
  action: ->
    Session.set "currentAppInfo",
      name: "bán hàng"
      navigationPartial:
        template: "orderNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      container: 'orderLayout'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /order trigger'
    return
  ]


merchantOrderRouter.route '/delivery',
  name: 'orderDelivery'
  action: ->
    Session.set "currentAppInfo",
      name: "tình trạng phiếu bán"
      navigationPartial:
        template: "orderDeliveryNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'orderDeliverySearch'
        contentDetail: 'orderDeliveryDetail'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /order trigger'
    return
  ]

merchantOrderRouter.route '/detail/:id',
  name: 'orderDetail'
  action: ->
    Session.set "currentAppInfo",
      name: "quản lý phiếu bán"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /order trigger'
    return
  ]




merchantRouter = Wings.Routers.merchantRouter
merchantRouter.route '/orderManager',
  name: 'orderManager'
  action: ->
    Session.set "currentAppInfo",
      name: "đơn hàng"

    BlazeLayout.render 'merchantLayout',
      content: 'orderManager'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]


merchantRouter.route '/billDetail',
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

merchantRouter.route '/billManager',
  name: 'billManager'
  action: ->
    Session.set "currentAppInfo",
      name: "tình trạng phiếu bán"
      navigationPartial:
        template: "orderDeliveryNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'billManager'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]


merchantRouter.route '/returnCustomer',
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
