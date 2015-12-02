Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineHyper 'customerDetail',
  created: ->
    console.log 'created customerDetail'
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

    activeClass: ->
      if @_id is Template.instance().currentCustomer.get()?._id then 'active' else ''


  events:
    "keyup input[name='searchFilter']": (event, template) ->