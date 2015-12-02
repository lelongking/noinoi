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

    BlazeLayout.render 'merchantLayout',
      content: 'customerGroup'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]