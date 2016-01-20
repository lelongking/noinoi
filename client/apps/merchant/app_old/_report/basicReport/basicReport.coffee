#scope = logics.basicReport
#Enums = Apps.Merchant.Enums
#
#lemon.defineApp Template.basicReport,
#  created: ->
#    option = {name: 'revenueBasicArea',template: 'revenueBasicAreaReport', data: {}}
#    Session.set("basicReportDynamics", option)
#    CustomerGroup.recalculateTotalCash()
#
#    self = @
#    self.autorun ()->
#      if dynamics = Session.get("basicReportDynamics")
#        if dynamics.template is 'revenueOfAreaReport'
#          scope.customers = Schema.customers.find({group: Session.get("basicReportDynamics").data._id},{$sort: {saleBillNo: -1}}).fetch()
#
#        if dynamics.template is 'productOfCustomerReport'
#          customerId = Session.get("basicReportDynamics").data._id
#          orders = Schema.orders.find({buyer: customerId}).fetch()
#          listProduct = {}
#          for order in orders
#            for detail in order.details
#              console.log detail
#              listProduct[detail.product]  = 0 unless listProduct[detail.product]
#              listProduct[detail.product] += detail.basicQuantity
#
#          scope.products = []
#          for key, value of listProduct
#            scope.products.push({name: Schema.products.findOne(key).name, totalCash: value})
#
#          console.log scope.products
#
#  helpers:
#    basicReportDynamics: -> Session.get("basicReportDynamics")
#    optionActiveClass: (templateName)-> 'active' if Session.get("basicReportDynamics").name is templateName
#
#  events:
#    "click .revenueBasicArea": ->
#      option = {name: 'revenueBasicArea',template: 'revenueBasicAreaReport', data: {}}
#      Session.set("basicReportDynamics", option)
##    "click .revenueBasicCustomer": ->
##      option = {name: 'revenueBasicCustomer',template: 'revenueBasicCustomerReport', data: {}}
##      Session.set("basicReportDynamics", option)
##    "click .revenueBasicStaff": ->
##      option = {name: 'revenueBasicStaff',template: 'revenueBasicStaffReport', data: {}}
##      Session.set("basicReportDynamics", option)
#
#    "click .revenueOfArea": ->
#      option = {name: 'revenueOfArea',template: 'revenueOfAreaReport', data: Schema.customerGroups.findOne({totalCash: {$gt: 0}})}
#      Session.set("basicReportDynamics", option)
#    "click .revenueOfCustomer": ->
#      option = {name: 'revenueOfCustomer',template: 'productOfCustomerReport', data: Schema.customers.findOne({debtCash: {$gt: 0}})}
#      Session.set("basicReportDynamics", option)
##    "click .revenueOfStaff": ->
##      option = {name: 'revenueOfStaff',template: 'revenueOfStaffReport', data: {}}
##      Session.set("basicReportDynamics", option)
