FlowRouter.route '/product',
  name: 'product'
  action: ->
    Session.set "currentAppInfo",
      name: "sản phầm"
      navigationPartial:
        template: "productManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'productManagement'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]

