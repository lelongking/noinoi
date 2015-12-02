merchantCustomerRouter = Wings.Routers.merchantCustomerRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/customer'
    name: "customerRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]


merchantCustomerRouter.route '/',
  name: 'customer'
  action: ->
    Session.set "currentAppInfo",
      name: "khách hàng"
      navigationPartial:
        template: "customerManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'customerSearch'
        contentDetail: 'customerDetail'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /customer trigger'
    return
  ]

merchantCustomerRouter.route '/new',
  name: 'newCustomer'
  triggersEnter: [ (context, redirect) ->
    console.log 'running /customer trigger'
    return
  ]

  action: (params, queryParams) ->
    console.log params, queryParams

    Session.set "currentAppInfo",
      name: "tạo mới khách hàng"
      navigationPartial:
        template: "customerManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'customerSearch'
        contentDetail: 'customerCreate'
    return

merchantCustomerRouter.route '/:customerId',
  name: 'customerId'
  triggersEnter: [ (context, redirect) ->
    console.log 'running /customer trigger'
    return
  ]

  action: (params, queryParams) ->
    console.log params, queryParams

    Session.set "currentAppInfo",
      name: "khách hàng"
      navigationPartial:
        template: "customerManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
    return
