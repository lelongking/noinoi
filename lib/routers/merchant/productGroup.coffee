merchantProductGroupRouter = Wings.Routers.merchantProductGroupRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/productGroup'
    name: "productGroupRouter"
    triggersEnter: [ (context, redirect, stop) ->
#      unless Roles.userIsInRole Meteor.user(), [ 'admin' ]
#        FlowRouter.go FlowRouter.path('dashboard')
#        stop()
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
    console.log 'running /provider trigger'
    return
  ]



merchantProductGroupRouter.route '/create',
  name: 'createProductGroup'
  action: (params, queryParams) ->
    console.log params, queryParams

    Session.set "currentAppInfo",
      name: "nhóm sản phẩm"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'productGroupSearch'
        contentDetail: 'productGroupCreate'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]