scope = logics.priceBook
lemon.addRoute
  template: 'priceBook'
#  waitOnDependency: 'merchantEssential'
  onBeforeAction: ->
    if @ready()
      FlowRouter.go('/merchant') unless User.hasManagerRoles()
      Apps.setup(scope, Apps.Merchant.priceBookInit, 'priceBook')
      Session.set "currentAppInfo",
        name: "bảng giá"
        navigationPartial:
          template: "priceBookNavigationPartial"
          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.priceBookReactive)
, Apps.Merchant.RouterBase


FlowRouter.route '/priceBook',
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
