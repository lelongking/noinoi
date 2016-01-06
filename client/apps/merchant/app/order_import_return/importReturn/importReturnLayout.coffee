scope = logics.providerReturn = {}
Enums = Apps.Merchant.Enums

Wings.defineApp 'importReturnLayout',
  created: ->
    self = this
    self.importReturn = new ReactiveVar({})
    self.returnParent = new ReactiveVar({})
    self.autorun ()->
      if Session.get('mySession')
        scope.currentProviderReturn = Schema.returns.findOne(Session.get('mySession').currentProviderReturn)
        Session.set 'currentProviderReturn', scope.currentProviderReturn
        self.importReturn.set(scope.currentProviderReturn)


        parent = Schema.imports.findOne(scope.currentProviderReturn?.parent)
        Session.set 'currentReturnParent', parent?.details
        self.returnParent.set(parent)


      #readonly 2 Select Khach Hang va Phieu Ban
      if providerReturn = Session.get('currentProviderReturn')
        $(".providerSelect").select2("readonly", false)
        $(".importSelect").select2("readonly", if providerReturn.owner then false else true)
      else
        $(".providerSelect").select2("readonly", true)
        $(".importSelect").select2("readonly", true)
#        ProviderSearch.search('')
#        UnitProductSearch.search('')
#
  rendered: ->
    if providerReturn = Session.get('currentProviderReturn')
      $(".providerSelect").select2("readonly", false)
      $(".importSelect").select2("readonly", if providerReturn.owner then false else true)
    else
      $(".providerSelect").select2("readonly", true)
      $(".importSelect").select2("readonly", true)


  helpers:
    importReturnData: ->
      importReturn: Template.instance().importReturn.get()
      returnParent: Template.instance().returnParent.get()

    tabProviderReturnOptions : -> tabProviderReturnOptions
    providerSelectOptions    : -> providerSelectOptions
    importSelectOptions      : -> importSelectOptions


    allowSuccessReturn: ->
      currentReturnDetails = Session.get('currentProviderReturn')?.details
      currentParentDetails = Session.get('currentReturnParent')

      if currentReturnDetails?.length > 0 and currentParentDetails?.length > 0
        for returnDetail in currentReturnDetails
          currentProductQuantity = 0

          for parentDetail in currentParentDetails
            if parentDetail.productUnit is returnDetail.productUnit
              currentProductQuantity += parentDetail.basicQuantityAvailable

          return 'disabled' if (currentProductQuantity - returnDetail.basicQuantity) < 0

      else
        return 'disabled'

  events:
    "click .returnSubmit": (event, template) ->
      if currentReturn = Session.get('currentProviderReturn')
        providerReturnLists = Return.findNotSubmitOf('provider').fetch()
        nextRow = providerReturnLists.getNextBy("_id", currentReturn._id)
        previousRow = providerReturnLists.getPreviousBy("_id", currentReturn._id)

        if nextRow = providerReturnLists.getNextBy("_id", currentReturn._id)
          Return.setReturnSession(nextRow._id, 'provider')
        else if previousRow = providerReturnLists.getPreviousBy("_id", currentReturn._id)
          Return.setReturnSession(previousRow._id, 'provider')
        else
          returnId = Return.insert(Enums.getValue('ReturnTypes', 'provider'))
          Return.setReturnSession(returnId, 'provider')

        scope.currentProviderReturn.submitProviderReturn()


providerSearch = (query) ->
  selector = {merchant: Merchant.getId(), billNo: {$gt: 0}}; options = {sort: {nameSearch: 1}}
  if(query.term)
    regExp = Helpers.BuildRegExp(query.term);
    selector =
      $and: [
        merchant : merchantId ? Merchant.getId()
        billNo   : {$gt: 0}
      ,
        $or: [{name: regExp}, {nameSearch: regExp}]
      ]
  Schema.providers.find(selector, options).fetch()

findImportByProvider = (providerId) ->
  importLists = []
  if providerId
    importLists = Schema.imports.find({
      merchant   : Merchant.getId()
      provider   : providerId
      importType : Enums.getValue('ImportTypes', 'success')
    }).fetch()
  importLists


formatProviderSearch = (item) ->
  if item
    name = "#{item.name} "; desc = if item.description then "(#{item.description})" else ""
    name + desc


tabProviderReturnOptions =
  source: -> Return.findNotSubmitOf('provider')
  currentSource: 'currentProviderReturn'
  caption: 'returnName'
  key: '_id'
  createAction  : ->
    returnId = Return.insert(Enums.getValue('ReturnTypes', 'provider'))
    Return.setReturnSession(returnId, 'provider')
  destroyAction : (instance) ->
    return -1 if !instance
    instance.remove()
    Return.findNotSubmitOf('provider').count()
  navigateAction: (instance) ->
    Return.setReturnSession(instance._id, 'provider')

providerSelectOptions =
  query: (query) -> query.callback
    results: providerSearch(query)
    text: 'name'
  initSelection: (element, callback) -> callback Schema.providers.findOne(scope.currentProviderReturn.owner)
  formatSelection: (item) -> "#{item.name}" if item
  formatResult: (item) -> "#{item.name}" if item
  id: '_id'
  placeholder: 'CHỌN NHÀ CUNG CẤP'
  readonly: -> true
  changeAction: (e) -> scope.currentProviderReturn.selectOwner(e.added._id)
  reactiveValueGetter: -> Session.get('currentProviderReturn')?.owner ? 'skyReset'

importSelectOptions =
  query: (query) -> query.callback
    results: findImportByProvider(Session.get('currentProviderReturn')?.owner)
    text: '_id'
  initSelection: (element, callback) -> callback Schema.imports.findOne(scope.currentProviderReturn?.parent)
  formatSelection: (item) -> "#{item.importCode}" if item
  formatResult: (item) -> "#{item.importCode}" if item
  id: '_id'
  placeholder: 'CHỌN PHIẾU'
  minimumResultsForSearch: -1
  readonly: -> true
  changeAction: (e) -> scope.currentProviderReturn.selectParent(e.added._id)
  reactiveValueGetter: -> Session.get('currentProviderReturn')?.parent ? 'skyReset'