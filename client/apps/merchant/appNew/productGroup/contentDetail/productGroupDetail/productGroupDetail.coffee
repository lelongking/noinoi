Enums = Apps.Merchant.Enums
scope = logics.productManagement

Wings.defineHyper 'productGroupDetail',
  created: ->
    self = this
    self.currentCustomerGroup = new ReactiveVar()
    self.autorun ()->
      if currentCustomerGroupId = Session.get('mySession')?.currentCustomerGroup
        productGroup = Schema.productGroups.findOne({_id: currentCustomerGroupId})
        productGroup = Schema.productGroups.findOne({isBase: true, merchant: Merchant.getId()}) unless productGroup

        if productGroup
          productGroup.productCount = if productGroup.productLists then productGroup.productLists.length else 0
          self.currentCustomerGroup.set(productGroup)
          Session.set "productSelectLists", Session.get('mySession').productSelected?[productGroup._id] ? []

  rendered: ->

  helpers:
    currentCustomerGroup: -> Template.instance().currentCustomerGroup.get()

  events:
    "keyup input[name='searchFilter']": (event, template) ->