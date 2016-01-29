merchantRouter = Wings.Routers.merchantRouter
merchantRouter.route '/interestRate',
  name: 'interestRate'
  action: ->
    Session.set "currentAppInfo",
      name: "lãi suất"

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon  : 'interestRateSearchCustomer'
        contentDetail : 'interestRateDetail'
    return

  triggersEnter: [ (context, redirect) ->
    return
  ]
