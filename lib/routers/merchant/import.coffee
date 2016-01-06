merchantImportRouter = Wings.Routers.merchantImportRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/import'
    name: "importRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]

merchantImportRouter.route '/',
  name: 'import'
  action: ->
    Session.set "currentAppInfo",
      name: "nhập kho"
      navigationPartial:
        template: "importNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      container: 'importLayout'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /import trigger'
    return
  ]