logics.sales = {} unless logics.sales
Enums = Apps.Merchant.Enums
scope = logics.sales
logics.sales.validation = {}

#------------------------barcodeHandler--------------------------------
scope.handleGlobalBarcodeInput = (e) ->
  if e.keyCode is 13
    globalBarcodeInput = Session.get("globalBarcodeInput")
    globalBarcodeInput = globalBarcodeInput.substr(0, globalBarcodeInput.length - 1)
    for i in [0..globalBarcodeInput.length]
      currentBarcode = globalBarcodeInput.substr(i - globalBarcodeInput.length)
      currentProduct = Schema.products.findOne({productCode: currentBarcode})
      console.log globalBarcodeInput, currentBarcode, currentProduct
      if currentProduct
        logics.sales.addOrderDetail(currentProduct._id)
        break
      break if currentBarcode.length < 7

    Session.set('globalBarcodeInput', '')
    return

  Session.set('globalBarcodeInput', Session.get('globalBarcodeInput') + String.fromCharCode(e.keyCode))
  if Session.get('globalBarcodeInput').length > 20
    Session.set('globalBarcodeInput', Session.get('globalBarcodeInput').substr(1))



scope.tabOptions =
  source: -> Order.findNotSubmitted()
  currentSource: 'currentOrder'
  caption: 'orderName'
  key: '_id'
  createAction  : -> Order.insert()
  destroyAction : (instance) -> if instance then Order.findNotSubmitted().count() if instance.remove() else -1
  navigateAction: (instance) -> Order.setSession(instance._id)

scope.debtDateOptions =
  reactiveSetter: (val) -> scope.currentOrder.changeDueDay(val)
  reactiveValue: -> Session.get('currentOrder')?.dueDay ? 0
  reactiveMax: -> 180
  reactiveMin: -> 0
  reactiveStep: -> 30
  others:
    forcestepdivisibility: 'none'



logics.sales.validation.orderDetail = (product, quality, price, discountCash)->
  if quality < 1
    console.log 'Số lượng nhỏ nhất là 1.'
    return false
  else if price < product.price
    console.log 'Giá sản phẩm không thể nhỏ hơn giá bán.'
    return false
  else if discountCash > price*quality
    console.log 'Giảm giá lớn hơn số tiền hiện có.'
    return false
  else
    return true

logics.sales.validation.checkProductInStockQuantity = (order, orderDetails)->
  product_ids = _.union(_.pluck(orderDetails, 'product'))
  products = Schema.products.find({_id: {$in: product_ids}}).fetch()

  orderDetails = _.chain(orderDetails)
  .groupBy("product")
  .map (group, key) ->
    return {
    product: key
    quality: _.reduce(group, ((res, current) -> res + current.quality), 0)
    }
  .value()
  try
    for currentDetail in orderDetails
      currentProduct = _.findWhere(products, {_id: currentDetail.product})
      if currentProduct.availableQuantity < currentDetail.quality
        throw {message: "lỗi", item: currentDetail}

    return {}
  catch e
    return {error: e}

scope.validation.getCrossProductQuantity = (productId, branchProductId, orderId) ->
  currentProduct = Schema.products.findOne(productId)
  if branchProduct  = Schema.branchProductSummaries.findOne(branchProductId)
    currentProduct.price       = branchProduct.price if branchProduct.price
    currentProduct.importPrice = branchProduct.importPrice if branchProduct.importPrice

    currentProduct.salesQuantity     = branchProduct.salesQuantity
    currentProduct.totalQuantity     = branchProduct.totalQuantity
    currentProduct.availableQuantity = branchProduct.availableQuantity
    currentProduct.inStockQuantity   = branchProduct.inStockQuantity
    currentProduct.returnQuantityByCustomer    = branchProduct.returnQuantityByCustomer
    currentProduct.returnQuantityByDistributor = branchProduct.returnQuantityByDistributor
    currentProduct.basicDetailModeEnabled     = branchProduct.basicDetailModeEnabled

  sameProducts = Schema.orderDetails.find({product: productId, order: orderId}).fetch()
  crossProductQuantity = 0
  crossProductQuantity += item.quality for item in sameProducts
  return {
  product: currentProduct
  quality: crossProductQuantity
  }




formatDefaultSearch  = (item) -> "#{item.display}" if item
findPaymentMethods   = (paymentMethodId)-> _.findWhere(Enums.PaymentMethods, {_id: paymentMethodId})
findDeliveryTypes    = (deliveryTypeId)-> _.findWhere(Enums.DeliveryTypes, {_id: deliveryTypeId})
customerSearch       = (query) -> CustomerSearch.search(query.term); CustomerSearch.getData({sort: {name: 1}})
formatCustomerSearch = (item) -> item.name if item
#    name = "#{item.name} "; desc = if item.description then "(#{item.description})" else ""
#    name + desc


scope.depositOptions =
  reactiveSetter: (val) -> scope.currentOrder.changeDepositCash(val)
  reactiveValue: -> Session.get('currentOrder')?.depositCash ? 0
  reactiveMax: -> 99999999999
  reactiveMin: -> 0
  reactiveStep: -> 1000
  others:
    forcestepdivisibility: 'none'

scope.discountOptions =
  reactiveSetter: (val) -> scope.currentOrder.changeDiscountCash(val)
  reactiveValue: -> Session.get('currentOrder')?.discountCash ? 0
  reactiveMax: -> 99999999999
  reactiveMin: -> 0
  reactiveStep: -> 1000
  others:
    forcestepdivisibility: 'none'

scope.customerSelectOptions =
  query: (query) -> query.callback
    results: customerSearch(query)
    text: 'name'
  initSelection: (element, callback) -> callback Schema.customers.findOne(scope.currentOrder.buyer)
  formatSelection: formatCustomerSearch
  formatResult: formatCustomerSearch
  id: '_id'
  placeholder: 'CHỌN NGƯỜI MUA'
  changeAction: (e) -> scope.currentOrder.changeBuyer(e.added._id)
  reactiveValueGetter: -> Session.get('currentOrder')?.buyer ? 'skyReset'

scope.paymentsDeliverySelectOptions =
  query: (query) -> query.callback
    results: Enums.DeliveryTypes
    text: '_id'
  initSelection: (element, callback) -> callback findDeliveryTypes(Session.get('currentOrder')?.paymentsDelivery)
  formatSelection: formatDefaultSearch
  formatResult: formatDefaultSearch
  placeholder: 'CHỌN PTGD'
  minimumResultsForSearch: -1
  changeAction: (e) -> scope.currentOrder.changePaymentsDelivery(e.added._id)
  reactiveValueGetter: -> findDeliveryTypes(Session.get('currentOrder')?.paymentsDelivery)

scope.paymentMethodSelectOptions =
  query: (query) -> query.callback
    results: Enums.PaymentMethods
    text: '_id'
  initSelection: (element, callback) -> callback findPaymentMethods(Session.get('currentOrder')?.paymentMethod)
  formatSelection: formatDefaultSearch
  formatResult: formatDefaultSearch
  placeholder: 'CHỌN PTGD'
  minimumResultsForSearch: -1
  changeAction: (e) -> scope.currentOrder.changePaymentMethod(e.added._id)
  reactiveValueGetter: -> findPaymentMethods(Session.get('currentOrder')?.paymentMethod)