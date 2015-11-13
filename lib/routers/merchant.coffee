#-------------------------------------------------------------------------------------------------------------------
merchantRouter = Wings.Routers.merchantRouter =
  Wings.Routers.loggedInRouter.group
    prefix: '/merchant'
    name: "merchant"
    triggersEnter: [ (context, redirect, stop) ->
      unless Roles.userIsInRole Meteor.user(), [ 'admin' ]
        FlowRouter.go FlowRouter.path('dashboard')
    ]

#-------------------------------------------------------------------------------------------------------------------
FlowRouter.route '/basicHistory',
  name: 'basicHistory'
  action: ->
    Session.set "currentAppInfo",
      name: "báo cáo"
      navigationPartial:
        template: "basicHistoryNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'basicHistory'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]



#FlowRouter.route '/saleProgram',
#  name: 'customerGroup'
#  action: ->
#    Session.set "currentAppInfo",
#      name: "nhóm khách hàng"
#
#    BlazeLayout.render 'merchantLayout',
#      content: 'customerGroup'
#    return
#
#  triggersEnter: [ (context, redirect) ->
#    console.log 'running /provider trigger'
#    return
#  ]
