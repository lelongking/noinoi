merchantHistoryRouter = Wings.Routers.merchantHistoryRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/history'
    name: "historyRouter"
    triggersEnter: [ (context, redirect, stop) ->
    ]

merchantHistoryRouter.route '/order',
  name: 'orderHistory'
  action: ->
    Session.set "currentAppInfo",
      name: "nhập kho"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      container: 'orderManager'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /history trigger'
    return
  ]

merchantHistoryRouter.route '/orderReturn',
  name: 'orderReturnHistory'
  action: ->
    Session.set "currentAppInfo",
      name: "nhập kho"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      container: 'orderReturnHistory'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /history trigger'
    return
  ]

merchantHistoryRouter.route '/import',
  name: 'importHistory'
  action: ->
    Session.set "currentAppInfo",
      name: "nhập kho"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      container: 'importHistory'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /history trigger'
    return
  ]

merchantHistoryRouter.route '/importReturn',
  name: 'importReturnHistory'
  action: ->
    Session.set "currentAppInfo",
      name: "nhập kho"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      container: 'importReturnHistory'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /history trigger'
    return
  ]