scope = logics.providerReturn
Enums = Apps.Merchant.Enums
Wings.defineApp 'providerReturn',
  helpers:
    tabProviderReturnOptions : -> scope.tabProviderReturnOptions
    providerSelectOptions    : -> scope.providerSelectOptions
    importSelectOptions      : -> scope.importSelectOptions


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

    availableQuantity: -> @basicQuantityAvailable/@conversion



  created: ->
    self = this
    self.autorun ()->
      if Session.get('mySession')
        scope.currentProviderReturn = Schema.returns.findOne(Session.get('mySession').currentProviderReturn)
        Session.set 'currentProviderReturn', scope.currentProviderReturn

        #load danh sach san pham cua phieu ban
        parent = Schema.imports.findOne(Session.get('currentProviderReturn')?.parent)
        Session.set 'currentReturnParent', parent?.details

      #readonly 2 Select Khach Hang va Phieu Ban
      if providerReturn = Session.get('currentProviderReturn')
        $(".providerSelect").select2("readonly", false)
        $(".importSelect").select2("readonly", if providerReturn.owner then false else true)
      else
        $(".providerSelect").select2("readonly", true)
        $(".importSelect").select2("readonly", true)
        ProviderSearch.search('')
        UnitProductSearch.search('')

  rendered: ->
    if providerReturn = Session.get('currentProviderReturn')
      $(".providerSelect").select2("readonly", false)
      $(".importSelect").select2("readonly", if providerReturn.owner then false else true)
    else
      $(".providerSelect").select2("readonly", true)
      $(".importSelect").select2("readonly", true)


  events:
#    "keyup input[name='searchFilter']": (event, template) ->
#      searchFilter  = template.ui.$searchFilter.val()
#      productSearch = Helpers.Searchify searchFilter
#      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch


    'click .addReturnDetail': (event, template)->
      console.log @
      scope.currentProviderReturn.addReturnDetail(@_id, @productUnit, 1, @price)
      event.stopPropagation()

    "click .returnSubmit": (event, template) ->
      if currentReturn = Session.get('currentProviderReturn')
        providerReturnLists = Return.findNotSubmitOf('provider').fetch()
        if nextRow = providerReturnLists.getNextBy("_id", currentReturn._id)
          Return.setReturnSession(nextRow._id, 'provider')
        else if previousRow = providerReturnLists.getPreviousBy("_id", currentReturn._id)
          Return.setReturnSession(previousRow._id, 'provider')
        else
          Return.setReturnSession(Return.insert(Enums.getValue('OrderTypes', 'provider')), 'provider')

        scope.currentProviderReturn.submitProviderReturn()