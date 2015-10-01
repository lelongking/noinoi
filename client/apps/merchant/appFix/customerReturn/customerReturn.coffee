scope = logics.customerReturn
Enums = Apps.Merchant.Enums
Wings.defineApp 'customerReturn',
  created: ->
    self = this
    self.autorun ()->
      if Session.get('mySession')
        scope.currentCustomerReturn = Schema.returns.findOne(Session.get('mySession').currentCustomerReturn)
        productQuantities = {}
        if scope.currentCustomerReturn
          for detail in scope.currentCustomerReturn.details
            productQuantities[detail.product] = 0 unless productQuantities[detail.product]
            productQuantities[detail.product] += detail.basicQuantity

          for detail in scope.currentCustomerReturn.details
            detail.returnQuantities = productQuantities[detail.product]

        Session.set 'currentCustomerReturn', scope.currentCustomerReturn

        #load danh sach san pham cua phieu ban
        if parent = Schema.orders.findOne(Session.get('currentCustomerReturn')?.parent)
          productQuantities = {}
          for detail in parent.details
            productQuantities[detail.product] = 0 unless productQuantities[detail.product]
            productQuantities[detail.product] += detail.basicQuantityAvailable

          for detail in parent.details
            detail.availableBasicQuantity = productQuantities[detail.product]
            detail.availableQuantity      = Math.floor(productQuantities[detail.product]/detail.conversion)

          Session.set 'currentReturnParent', parent.details

      #readonly 2 Select Khach Hang va Phieu Ban
      if customerReturn = Session.get('currentCustomerReturn')
        $(".customerSelect").select2("readonly", false)
        $(".orderSelect").select2("readonly", if customerReturn.owner then false else true)
      else
        $(".customerSelect").select2("readonly", true)
        $(".orderSelect").select2("readonly", true)
    CustomerSearch.search('')
    UnitProductSearch.search('')

  rendered: ->
    if customerReturn = Session.get('currentCustomerReturn')
      $(".customerSelect").select2("readonly", false)
      $(".orderSelect").select2("readonly", if customerReturn.owner then false else true)
    else
      $(".customerSelect").select2("readonly", true)
      $(".orderSelect").select2("readonly", true)


  helpers:
    tabCustomerReturnOptions : -> scope.tabCustomerReturnOptions
    customerSelectOptions    : -> scope.customerSelectOptions
    orderSelectOptions       : -> scope.orderSelectOptions
    allReturnProduct         : -> scope.managedReturnProductList


    allowSuccessReturn: ->
      currentReturnDetails = Session.get('currentCustomerReturn')?.details
      currentParentDetails = Session.get('currentReturnParent')

      if currentReturnDetails?.length > 0 and currentParentDetails?.length > 0
        for returnDetail in currentReturnDetails
          for parentDetail in currentParentDetails
            if parentDetail.product is returnDetail.product
              currentProductQuantity = parentDetail.availableBasicQuantity - returnDetail.returnQuantities

          #chua biet lam gi ???
          if parentDetail.return?.length > 0
            (currentProductQuantity -= item.basicQuantity) for item in parentDetail.return

          console.log currentProductQuantity, returnDetail.basicQuantity, (currentProductQuantity - returnDetail.basicQuantity) < 0
#          return 'disabled' if (currentProductQuantity - returnDetail.basicQuantity) < 0
          return 'disabled' if currentProductQuantity < 0

      else
        return 'disabled'



  events:
#    "keyup input[name='searchFilter']": (event, template) ->
#      searchFilter  = template.ui.$searchFilter.val()
#      productSearch = Helpers.Searchify searchFilter
#      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch


    'click .addReturnDetail': (event, template)->
      scope.currentCustomerReturn.addReturnDetail(@_id, @productUnit, 1, @price)
      event.stopPropagation()

    "click .returnSubmit": (event, template) ->
      if currentReturn = Session.get('currentCustomerReturn')
        customerReturnLists = Return.findNotSubmitOf('customer').fetch()
        if nextRow = customerReturnLists.getNextBy("_id", currentReturn._id)
          Return.setReturnSession(nextRow._id, 'customer')
        else if previousRow = customerReturnLists.getPreviousBy("_id", currentReturn._id)
          Return.setReturnSession(previousRow._id, 'customer')
        else
          Return.setReturnSession(Return.insert(Enums.getValue('OrderTypes', 'customer')), 'customer')

        scope.currentCustomerReturn.submitCustomerReturn()