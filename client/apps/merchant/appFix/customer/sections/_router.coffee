FlowRouter.route '/customer',
  name: 'customer'
  action: ->
    Session.set "currentAppInfo",
      name: "khách hàng"
      navigationPartial:
        template: "customerManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'customerManagement'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /customer trigger'
    return
  ]

FlowRouter.route '/customer/:customerId',
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
      content: 'customerManagement'
    return

