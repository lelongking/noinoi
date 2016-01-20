Enums = Apps.Merchant.Enums

Wings.defineApp 'statisticLayout',
  created: ->
    Session.set("statisticDynamics", {template: 'revenueBasicAreaReport', data: {}})

    self = @
    self.autorun ()->


  helpers:
    statisticDynamics: -> Session.get("statisticDynamics")
    optionActiveClass: (template)-> 'active' if Session.get("statisticDynamics")?.template is template

  events:
    "click .basicStatisticCustomerGroup": ->
      option = template: 'basicStatisticCustomerGroup', data: {}
      Session.set("statisticDynamics", option)
    "click .basicStatisticCustomer": ->
      option = template: 'basicStatisticCustomer', data: {}
      Session.set("statisticDynamics", option)
    "click .basicStatisticProvider": ->
      option = template: 'basicStatisticProvider', data: {}
      Session.set("statisticDynamics", option)

