Enums = Apps.Merchant.Enums

Wings.defineApp 'statisticLayout',
  created: ->
    Session.set("statisticDynamics", {template: 'generalStatisticCustomerGroup', data: {}})

    self = @
    self.autorun ()->


  helpers:
    statisticDynamics: -> Session.get("statisticDynamics")
    optionActiveClass: (template)-> 'active' if Session.get("statisticDynamics")?.template is template

  events:
    "click .generalStatisticCustomerGroup": ->
      option = template: 'generalStatisticCustomerGroup', data: {}
      Session.set("statisticDynamics", option)
    "click .merchantReportDayTimeline": ->
      option = template: 'merchantReportDayTimeline', data: {}
      Session.set("statisticDynamics", option)

