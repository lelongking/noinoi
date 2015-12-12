merchantProductGroupRouter = Wings.Routers.merchantProductGroupRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/productGroup'
    name: "productGroupRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]


merchantProductGroupRouter.route '/',
  name: 'productGroup'
  action: ->
    Session.set "currentAppInfo",
      name: "nhóm sản phẩm"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'productGroupSearch'
        contentDetail: 'productGroupDetail'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /product trigger'
    return
  ]
