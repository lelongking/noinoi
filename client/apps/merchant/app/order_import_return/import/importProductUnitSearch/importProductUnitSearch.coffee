Enums = Apps.Merchant.Enums
scope = logics.sales = {}

Wings.defineApp 'importProductUnitSearch',
  created: ->
    self = this
    self.autorun ()->
    UnitProductSearch.search('')

  rendered: ->
  destroyed: ->

#  helpers:


  events:
    "keyup input[name='searchFilter']": (event, template) ->
      searchFilter  = template.ui.$searchFilter.val()
      productSearch = Helpers.Searchify searchFilter
      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch

    'click .addProductUnitOnImport': (event, template)->
      productUnit = @; currentImport = Template.currentData()
      if productUnit.inventoryInitial
        currentImport.addImportDetail(productUnit._id)
      event.stopPropagation()