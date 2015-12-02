merchantRouter = Wings.Routers.merchantRouter







merchantRouter.route '/import',
  name: 'import'
  action: ->
    Session.set "currentAppInfo",
      name: "nhập kho"

    BlazeLayout.render 'merchantLayout',
      content: 'import'
    return

  triggersEnter: [ (context, redirect) ->
    merchantRouter.go('/merchant') unless User.hasManagerRoles()
    console.log 'running /provider trigger'
    return
  ]


merchantRouter.route '/order',
  name: 'order'
  action: ->
    Session.set "currentAppInfo",
      name: "bán hàng"

    BlazeLayout.render 'merchantLayout',
      content: 'order'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]



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

    BlazeLayout.render 'merchantLayout',
      content: 'billManager'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]





merchantRouter.route '/returnProvider',
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


merchantRouter.route '/transaction',
  name: 'transaction'
  action: ->
    Session.set "currentAppInfo",
      name: "thu chi - tài chính"
      navigationPartial:
        template: "transactionNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'transaction'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]
