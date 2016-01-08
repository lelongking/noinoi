scope = logics.customerReturn
Enums = Apps.Merchant.Enums
Wings.defineApp 'orderReturnLayout',
  created: ->
    self = this
    self.orderReturn = new ReactiveVar({})
    self.returnParent = new ReactiveVar({})
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

          self.orderReturn.set(scope.currentCustomerReturn)
          Session.set 'currentCustomerReturn', scope.currentCustomerReturn

          parent = parent = Schema.orders.findOne(scope.currentCustomerReturn.parent)
          Session.set 'currentReturnParent', parent?.details
          self.returnParent.set(parent)


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
    orderReturnData: ->
      orderReturn: Template.instance().orderReturn.get()
      returnParent: Template.instance().returnParent.get()

    tabCustomerReturnOptions : -> tabCustomerReturnOptions
    customerSelectOptions    : -> customerSelectOptions
    orderSelectOptions       : -> orderSelectOptions



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







tabCustomerReturnOptions =
  source: -> Return.findNotSubmitOf('customer')
  currentSource: 'currentCustomerReturn'
  caption: 'returnName'
  key: '_id'
  createAction  : ->
    returnId = Return.insert(Enums.getValue('OrderTypes', 'customer'))
    Return.setReturnSession(returnId, 'customer')
  destroyAction : (instance) ->
    return -1 if !instance
    instance.remove()
    Return.findNotSubmitOf('customer').count()
  navigateAction: (instance) ->
    Return.setReturnSession(instance._id, 'customer')

formatCustomerSearch = (item) -> item.name if item


customerSearch = (query) ->
  selector = {merchant: Merchant.getId(), saleBillNo: {$gt: 0}}; options = {sort: {nameSearch: 1}}
  if(query.term)
    regExp = Helpers.BuildRegExp(query.term);
    selector =
      $and: [
        merchant  : merchantId ? Merchant.getId()
        saleBillNo: {$gt: 0}
      ,
        $or: [{name: regExp}, {nameSearch: regExp}]
      ]
  Schema.customers.find(selector, options).fetch()

customerSelectOptions =
  query: (query) -> query.callback
    results: customerSearch(query)
    text: 'name'
  initSelection: (element, callback) -> callback Schema.customers.findOne(scope.currentCustomerReturn.owner)
  formatSelection: (item) -> item.name if item
  formatResult: (item) -> item.name if item
  id: '_id'
  placeholder: 'CHỌN KHÁCH HÀNG'
  readonly: -> true
  changeAction: (e) -> scope.currentCustomerReturn.selectOwner(e.added._id)
  reactiveValueGetter: -> Session.get('currentCustomerReturn')?.owner ? 'skyReset'



findOrderByCustomer = (customerId) ->
  orderLists = []
  if customerId
    orderLists = Schema.orders.find({
      merchant    : Merchant.getId()
      buyer       : customerId
      orderType   : Enums.getValue('OrderTypes', 'success')
      orderStatus : Enums.getValue('OrderStatus', 'finish')
    }).fetch()
  orderLists

orderSelectOptions =
  query: (query) -> query.callback
    results: findOrderByCustomer(Session.get('currentCustomerReturn')?.owner)
    text: '_id'
  initSelection: (element, callback) -> callback Schema.orders.findOne(scope.currentCustomerReturn?.parent)
  formatSelection: (item) -> "#{item.billNoOfBuyer}" if item
  formatResult: (item) -> "#{item.billNoOfBuyer}" if item
  id: '_id'
  placeholder: 'CHỌN PHIẾU BÁN'
  minimumResultsForSearch: -1
  readonly: -> true
  changeAction: (e) -> scope.currentCustomerReturn.selectParent(e.added._id)
  reactiveValueGetter: -> Session.get('currentCustomerReturn')?.parent ? 'skyReset'
