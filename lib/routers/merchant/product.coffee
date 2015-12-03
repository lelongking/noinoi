merchantRouter = Wings.Routers.merchantRouter
merchantRouter.route '/priceBook',
  name: 'priceBook'
  action: ->
    Session.set "currentAppInfo",
      name: "bảng giá"

    BlazeLayout.render 'merchantLayout',
      content: 'priceBook'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]

merchantRouter.route '/product',
  name: 'product'
  action: ->
    Session.set "currentAppInfo",
      name: "sản phầm"
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
    return
  ]


merchantRouter.route '/productGroup',
  name: 'productGroup'
  action: ->
    Session.set "currentAppInfo",
      name: "nhóm sản phẩm"

    BlazeLayout.render 'merchantLayout',
      content: 'productGroup'
    return

  triggersEnter: [ (context, redirect) ->
    return
  ]