Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineApp 'customerManagement',
  created: ->
    self = this
    self.currentCustomer = new ReactiveVar()
    self.autorun ()->
      if customerId = Session.get('mySession')?.currentCustomer
#        Wings.SubsManager.subscribe('getCustomerId', customerId)
        self.currentCustomer.set(Schema.customers.findOne(customerId))

  rendered: ->


  helpers:
    currentCustomer: -> Template.instance().currentCustomer.get()