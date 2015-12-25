merchantProductRouter = Wings.Routers.merchantProductGroupRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/product'
    name: "productRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]


merchantProductRouter.route '/',
  name: 'product'
  action: ->
    Session.set "currentAppInfo",
      name: "sản phẩm"
      navigationPartial:
        template: "productManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'productSearch'
        contentDetail: 'productDetail'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /product trigger'
    return
  ]

merchantProductRouter.route '/create',
  name: 'createProduct'
  action: (params, queryParams) ->
    Session.set "currentAppInfo",
      name: "sản phẩm"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'productSearch'
        contentDetail: 'productCreate'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /customer trigger'
    return
  ]