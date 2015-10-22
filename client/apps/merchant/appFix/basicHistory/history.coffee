scope = logics.basicHistory

lemon.defineApp Template.basicHistory,
  created: ->
    option = {name: 'customerGroup',template: 'historySynthesisDebts', data: {}}
    Session.set("basicHistoryDynamics", option)
    Session.set("basicHistoryCustomerSearchText", '')
    Session.set("basicHistoryProviderSearchText", '')
    Session.set("basicHistoryIsShowCustomer", true)

#    self = this
#    self.isShowCustomer = new ReactiveVar(true)
#    self.autorun ()->
#      if customerId = Session.get('mySession')?.currentCustomer
#        self.currentCustomer.set(Schema.customers.findOne(customerId))

  helpers:
    isShowCustomer: -> Session.get("basicHistoryIsShowCustomer")
    basicHistoryDynamics: -> Session.get("basicHistoryDynamics")
    isActive: (name)-> 'active' if Session.get("basicHistoryDynamics").name is name

  events:
    "click .icon-print-6": (event, template)->
      name = 'tong_hop_cong_no_' + moment().format('MM/YYYY')
      blobURL = Apps.Merchant.tableToExcel('historyTable', 'W3C Example Table')
      $(event.target).attr 'download', name + '.xls'
      $(event.target).attr 'href', blobURL
