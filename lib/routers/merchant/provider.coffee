merchantProviderRouter = Wings.Routers.merchantProviderRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/provider'
    name: "providerRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]

merchantProviderRouter.route '/',
  name: 'provider'
  action: (params, queryParams)->
    Session.set "currentAppInfo",
      name: "nhà cung cấp"
      navigationPartial:
        template: "providerManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'providerSearch'
        contentDetail: 'providerDetail'
    return

  triggersEnter: [ (context, redirect, stop) ->
    console.log 'running /provider trigger'
    return
  ]

merchantProviderRouter.route '/create',
  name: 'createProvider'
  action: (params, queryParams) ->
    Session.set "currentAppInfo",
      name: "nhà cung cấp"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'providerSearch'
        contentDetail: 'providerCreate'
    return

  triggersEnter: [ (context, redirect, stop) ->
    console.log 'running /customer trigger'
    return
  ]