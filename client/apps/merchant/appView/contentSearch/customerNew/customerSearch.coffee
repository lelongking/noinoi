Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineHyper 'createNew',
  created: ->
    console.log 'created customerSearch'
    self = this
    self.currentCustomer = new ReactiveVar()
    self.searchFilter = new ReactiveVar('')
    self.autorun ()->
      if customerId = Session.get('mySession')?.currentCustomer
        self.currentCustomer.set(Schema.customers.findOne(customerId))

  rendered: ->

  helpers:
    currentCustomer: ->
      Template.instance().currentCustomer.get()


  events:
    "click .create-new-customer": (event, template) ->
      FlowRouter.go('customerCreate')

    "click .caption.inner.toCustomerGroup": (event, template) ->
      FlowRouter.go('customerGroup')
