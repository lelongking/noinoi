Enums = Apps.Merchant.Enums
scope = logics.productManagement

Wings.defineHyper 'productGroupDetail',
  created: ->
    self = this
    self.currentProductGroup = new ReactiveVar()
    self.autorun ()->
      if currentProductGroupId = Session.get('mySession')?.currentProductGroup
        productGroup = Schema.productGroups.findOne({_id: currentProductGroupId})
        productGroup = Schema.productGroups.findOne({isBase: true, merchant: Merchant.getId()}) unless productGroup

        if productGroup
          self.currentProductGroup.set(productGroup)
          Session.set "productSelectLists", Session.get('mySession').productSelected?[productGroup._id] ? []

  rendered: ->

  helpers:
    currentProductGroup: -> Template.instance().currentProductGroup.get()

  events:
    "keyup input[name='searchFilter']": (event, template) ->