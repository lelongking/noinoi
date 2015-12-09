Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineAppContainer 'customerDetail',
  created: ->
  rendered: ->
  destroyed: ->

  helpers:
    currentCustomer: ->
      if customerId = Session.get('mySession')?.currentCustomer
        Schema.customers.findOne({_id: customerId})


#  events:

