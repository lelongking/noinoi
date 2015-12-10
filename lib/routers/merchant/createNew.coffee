merchantRouter = Wings.Routers.merchantRouter
merchantRouter.route '/createNew/customerCreate',
  name: 'customerCreate123123'

  triggersEnter: [ (context, redirect, stop) ->
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
        contentAddon: 'createNew'
        contentDetail: 'customerCreate'
    return

