merchantPriceBookRouter = Wings.Routers.merchantPriceBookRouter =
  Wings.Routers.merchantRouter.group
    prefix: '/priceBook'
    name: "priceBookRouter"
    triggersEnter: [ (context, redirect, stop) ->
#      unless Roles.userIsInRole Meteor.user(), [ 'admin' ]
#        FlowRouter.go FlowRouter.path('dashboard')
#        stop()
    ]



merchantPriceBookRouter.route '/',
  name: 'priceBook'
  action: ->
    Session.set "currentAppInfo",
      name: "bảng giá"
      navigationPartial:
        template: ""
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'priceBookSearch'
        contentDetail: 'priceBookDetail'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]