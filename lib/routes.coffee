Wings.SubsManager = new SubsManager({cacheLimit: 9999, expireIn: 9999})

#Module 'Wings.Merchant',
#  router:
#
#  customer:
#    url: ''
#    name: ''
#    render:




BlazeLayout.setRoot('body') if Meteor.isClient
FlowRouter.notFound =
  subscriptions: ->
  action: ->


FlowRouter.route '/saleProgram',
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
      setups.metroHome.orderApp
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