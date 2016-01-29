Enums = Apps.Merchant.Enums
Wings.defineAppContainer 'interestRateDetail',
  created: ->
    $(".nano.customerDetail").nanoScroller({ scroll: 'bottom' })
  rendered: ->
    $(".nano.customerDetail").nanoScroller({ scroll: 'bottom' })
  destroyed: ->

  helpers:
    currentCustomer: ->
      customerId = Session.get('mySession')?.currentCustomer
      if customerId
        Schema.customers.findOne({_id: customerId})


#  events:

