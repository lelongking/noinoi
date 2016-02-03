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
        customer = Schema.customers.findOne({_id: customerId})

        if customer.interestAmount is 0
          Session.set('editInterestRateManager', true)
          Session.set('customerManagementIsShowCustomerDetail', false)
          Session.set('customerManagementIsEditMode', false)
          Session.set("customerManagementShowEditCommand", false)
      customer

#  events:

