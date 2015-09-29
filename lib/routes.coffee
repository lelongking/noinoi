Wings.SubsManager = new SubsManager()
BlazeLayout.setRoot('body') if Meteor.isClient
FlowRouter.notFound =
  subscriptions: ->
  action: ->
#
#merchantRoutes = FlowRouter.group(
#  name: 'merchant'
#  prefix: '/'
#  triggersEnter: [ (context, redirect) ->
#    console.log 'running group triggers'
#    return
#  ])


FlowRouter.route '/',
  name: 'home'
  action: ->
    BlazeLayout.render 'about'
    return
  triggersEnter: [ (context, redirect) ->
    console.log 'running /admin trigger'
    return
  ]

FlowRouter.route '/merchant',
  name: 'metro'
  action: ->
    Session.set "currentAppInfo", name: "trung tâm"

    BlazeLayout.render 'merchantLayout',
      content: 'merchantHome'
      contentData: setups.metroHome.metroData

    return
  triggersEnter: [ (context, redirect) ->
    console.log 'running /admin trigger'
    return
  ]


FlowRouter.route '/customer',
  name: 'customer'
  action: ->
    Session.set "currentAppInfo",
      name: "khách hàng"
      navigationPartial:
        template: "customerManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'customerManagement'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /admin trigger'
    return
  ]










setups.metroHome.metroData = [
  classGroup: 'tile-group-2'
  dataGroup: [
      setups.metroHome.customerApp
    ,
      setups.metroHome.providerApp
    ,
      setups.metroHome.productApp
  ]
,
  classGroup: 'tile-group-2'
  dataGroup: [
      setups.metroHome.customerGroupApp
    ,
      setups.metroHome.transactionApp
    ,
      setups.metroHome.saleApp
    ,
      setups.metroHome.billManagerApp
    ,
      setups.metroHome.importApp
    ,
      setups.metroHome.warehouseApp
    ,
      setups.metroHome.productGroupApp
    ,
      setups.metroHome.priceBookApp
  ]
,
  classGroup: 'tile-group-2'
  dataGroup: [
      setups.metroHome.staffManagementApp
    ,
      setups.metroHome.merchantOptionsApp
    ,
      setups.metroHome.customerReturnApp
    ,
      setups.metroHome.orderManagerApp
    ,
      setups.metroHome.providerReturnApp
    ,
      setups.metroHome.basicHistoryApp
    ,
      setups.metroHome.programManagerApp
    ,
      setups.metroHome.basicReportApp
  ]
]