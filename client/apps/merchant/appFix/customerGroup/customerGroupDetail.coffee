Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineHyper 'customerGroupDetail',
  created: ->
    self = this
    self.autorun ()->
      if currentCustomerGroupId = Session.get('mySession')?.currentCustomerGroup
        customerGroup = Schema.customerGroups.findOne({_id: currentCustomerGroupId})
        customerGroup = Schema.customerGroups.findOne({isBase: true, merchant: Merchant.getId()}) unless customerGroup
        if customerGroup
          customerGroup.customerCount = if customerGroup.customerLists then customerGroup.customerLists.length else 0
          scope.currentCustomerGroup = customerGroup

  rendered: ->

  helpers:
    currentCustomerGroup: -> Session.get("currentCustomerGroup")

    activeClass: ->
      if @_id is Template.instance().currentCustomer.get()?._id then 'active' else ''


  events:
    "keyup input[name='searchFilter']": (event, template) ->