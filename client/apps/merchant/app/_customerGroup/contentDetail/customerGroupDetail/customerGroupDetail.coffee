Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineHyper 'customerGroupDetail',
  created: ->
    self = this
    self.currentCustomerGroup = new ReactiveVar()
    self.autorun ()->
      if currentCustomerGroupId = Session.get('mySession')?.currentCustomerGroup
        customerGroup = Schema.customerGroups.findOne({_id: currentCustomerGroupId})
        customerGroup = Schema.customerGroups.findOne({isBase: true, merchant: Merchant.getId()}) unless customerGroup

        if customerGroup
          customerGroup.customerCount = if customerGroup.customerLists then customerGroup.customerLists.length else 0
          self.currentCustomerGroup.set(customerGroup)
          Session.set "customerSelectLists", Session.get('mySession').customerSelected?[customerGroup._id] ? []

  rendered: ->

  helpers:
    currentCustomerGroup: -> Template.instance().currentCustomerGroup.get()

  events:
    "keyup input[name='searchFilter']": (event, template) ->