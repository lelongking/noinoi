Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineHyper 'customerGroupDetail',
  created: ->
    self = this
    self.currentProductGroup = new ReactiveVar()
    self.autorun ()->
      if currentProductGroupId = Session.get('mySession')?.currentProductGroup
        customerGroup = Schema.customerGroups.findOne({_id: currentProductGroupId})
        customerGroup = Schema.customerGroups.findOne({isBase: true, merchant: Merchant.getId()}) unless customerGroup

        if customerGroup
          customerGroup.customerCount = if customerGroup.customerLists then customerGroup.customerLists.length else 0
          self.currentProductGroup.set(customerGroup)
          Session.set "customerSelectLists", Session.get('mySession').customerSelected?[customerGroup._id] ? []

  rendered: ->

  helpers:
    currentProductGroup: -> Template.instance().currentProductGroup.get()

  events:
    "keyup input[name='searchFilter']": (event, template) ->