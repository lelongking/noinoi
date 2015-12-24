Enums = Apps.Merchant.Enums
scope = logics.providerReturn = {}

Wings.defineApp 'importReturnProductSearch',
  created: ->
    self = this
    self.autorun ()->
      if Session.get('mySession')
        #load danh sach san pham cua phieu nhap
        parent = Schema.imports.findOne(Session.get('currentProviderReturn')?.parent)
        Session.set 'currentReturnParent', parent?.details


  rendered: ->



  destroyed: ->



  helpers:
    availableQuantity: -> @basicQuantityAvailable/@conversion



  events:
    "keyup input[name='searchFilter']": (event, template) ->
      searchFilter  = template.ui.$searchFilter.val()
      productSearch = Helpers.Searchify searchFilter
#      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch

    'click .addReturnDetail': (event, template)->
      currentImportReturn = Template.currentData().importReturn
      currentImportReturn.addReturnDetail(@_id, @productUnit, 1, @price)
      event.stopPropagation()
