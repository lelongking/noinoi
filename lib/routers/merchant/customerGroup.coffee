merchantCustomerGroupRouter = Wings.Routers.merchantCustomerGroupRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/customerGroup'
    name: "customerGroupRouter"
    triggersEnter: [ (context, redirect, stop) ->
#      unless Roles.userIsInRole Meteor.user(), [ 'admin' ]
#        FlowRouter.go FlowRouter.path('dashboard')
#        stop()
    ]



merchantCustomerGroupRouter.route '/',
  name: 'customerGroup'
  action: ->
    Session.set "currentAppInfo",
      name: "nhóm khách hàng"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'customerGroupSearch'
        contentDetail: 'customerGroupDetail'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]



merchantCustomerGroupRouter.route '/create',
  name: 'createCustomerGroup'
  action: (params, queryParams) ->
    console.log params, queryParams

    Session.set "currentAppInfo",
      name: "nhóm khách hàng"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'customerGroupSearch'
        contentDetail: 'customerGroupCreate'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]