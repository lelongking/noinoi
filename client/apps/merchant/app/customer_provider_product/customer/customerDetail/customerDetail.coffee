Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineAppContainer 'customerDetail',
  created: ->
  rendered: ->
    $(".nano.customerDetail").nanoScroller({ scroll: 'bottom' })
  destroyed: ->

  helpers:
    currentCustomer: ->
      if customerId = Session.get('mySession')?.currentCustomer
        Schema.customers.findOne({_id: customerId})


#  events:

