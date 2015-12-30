scope = logics.billDetail = {}
Enums = Apps.Merchant.Enums
Wings.defineApp 'orderDetailLayout',
  helpers:
    currentBill: -> Session.get('currentBillHistory')
    depositOptions: -> scope.depositOptions
    discountOptions: -> scope.discountOptions
    sellerSelectOptions: -> scope.sellerSelectOptions
    customerSelectOptions: -> scope.customerSelectOptions
    paymentMethodSelectOptions: -> scope.paymentMethodSelectOptions
    paymentsDeliverySelectOptions: -> scope.paymentsDeliverySelectOptions

  created: ->
    self = this
    self.autorun ()->
      if Session.get('currentBillHistory')
        scope.currentBillHistory = Schema.orders.findOne Session.get('currentBillHistory')._id
        Session.set('currentBillHistory', scope.currentBillHistory)

      if newBuyerId = Session.get('currentBillHistory')?.buyer
        if !(oldBuyerId = Session.get('currentBuyer')?._id) or oldBuyerId isnt newBuyerId
          Session.set('currentBuyer', Schema.customers.findOne newBuyerId)
      else
        Session.set 'currentBuyer'

    UnitProductSearch.search('')

  destroyed: ->
    Session.set("editingId")
    Session.set("currentBillHistory")

  events:
    "click .caption.inner": (event, template) ->
      scope.currentBillHistory.addDetail(@_id); event.stopPropagation() if User.hasManagerRoles()

    "click .accountingConfirm": (event, template) ->
      order = scope.currentBillHistory
      Meteor.call 'orderAccountConfirm', order._id, (error, result) ->
        Meteor.call 'orderExportConfirm', order._id, (error, result) ->
          if order.paymentsDelivery is Enums.getValue('DeliveryTypes', 'direct')
            Meteor.call 'orderSuccessConfirm', order._id, (error, result) ->
              Meteor.call 'orderFinishConfirm', order._id, (error, result) ->

          Session.set("currentBillHistory")
          Session.set("editingId")
          FlowRouter.go 'billManager'

    "click .export-command": (event, template) ->
      dataArray = []; customer = Session.get("currentBuyer")
      headOrder    = ['Sản Phẩm', 'ĐVT', 'Thùng', 'Chai/Gói', '']
      headCustomer = ['Khách Hàng', 'Số ĐT', 'Địa Chỉ', 'Số Phiếu']
      headColumns = headOrder.concat(headCustomer)
      dataArray[index] = [head] for head, index in headColumns

      orderDataLength = 1
      if currentOrder = scope.currentBillHistory
        for detail in currentOrder.details
          orderDataLength += 1
          if product = Schema.products.findOne(detail.product)
            unitQuantity = if product.units[1] then Math.floor(detail.basicQuantity/product.units[1].conversion) else 0

            array = [
              product.name
              product.unitName()
              unitQuantity
              detail.basicQuantity
            ]
            dataArray[index].push(array[index] ? '') for head, index in headOrder


      customerData = [
        customer?.name
        customer?.profiles?.phone
        customer?.profiles?.address
        currentOrder.orderCode
      ]
      dataArray[index+headOrder.length].push(customerData[index] ? '') for head, index in headCustomer
      maxLength = 2
      maxLength = orderDataLength if orderDataLength > maxLength



      console.log 'export'
      link = window.document.createElement('a')
      link.setAttribute 'href', 'data:text/csv;charset=utf-8,' + encodeURI(Helpers.JSON2CSV(dataArray, maxLength))
      link.setAttribute 'download', 'xuat_kho.csv'
      link.click()




formatDefaultSearch  = (item) -> "#{item.display}" if item
findPaymentMethods   = (paymentMethodId)-> _.findWhere(Enums.PaymentMethods, {_id: paymentMethodId})
findDeliveryTypes    = (deliveryTypeId)-> _.findWhere(Enums.DeliveryTypes, {_id: deliveryTypeId})
customerSearch       = (query) -> CustomerSearch.search(query.term); CustomerSearch.getData({sort: {name: 1}})
formatCustomerSearch = (item) ->
  if item
    name = "#{item.name} "; desc = if item.description then "(#{item.description})" else ""
    name + desc


scope.depositOptions =
  reactiveSetter: (val) -> scope.currentBillHistory.changeDepositCash(val)
  reactiveValue: -> Session.get('currentBillHistory')?.depositCash ? 0
  reactiveMax: -> 99999999999
  reactiveMin: -> 0
  reactiveStep: -> 1000
  others:
    forcestepdivisibility: 'none'

scope.discountOptions =
  reactiveSetter: (val) -> scope.currentBillHistory.changeDiscountCash(val)
  reactiveValue: -> Session.get('currentBillHistory')?.discountCash ? 0
  reactiveMax: -> 99999999999
  reactiveMin: -> 0
  reactiveStep: -> 1000
  others:
    forcestepdivisibility: 'none'

scope.customerSelectOptions =
  query: (query) -> query.callback
    results: customerSearch(query)
    text: 'name'
  initSelection: (element, callback) -> callback Schema.customers.findOne(scope.currentBillHistory.buyer)
  formatSelection: formatCustomerSearch
  formatResult: formatCustomerSearch
  id: '_id'
  placeholder: 'CHỌN NGƯỜI MUA'
  readonly: -> true
  changeAction: (e) -> scope.currentBillHistory.changeBuyer(e.added._id)
  reactiveValueGetter: -> Session.get('currentBillHistory')?.buyer ? 'skyReset'

scope.sellerSelectOptions =
  query: (query) -> query.callback
    results: [Meteor.users.findOne(scope.currentBillHistory.seller).profile]
    text: 'name'
  initSelection: (element, callback) -> callback Meteor.users.findOne(scope.currentBillHistory?.seller)?.profile
  formatSelection: formatCustomerSearch
  formatResult: formatCustomerSearch
  id: 'name'
  placeholder: 'CHỌN NGƯỜI MUA'
  readonly: -> true
  changeAction: (e) -> scope.currentBillHistory.changeBuyer(e.added._id)
  reactiveValueGetter: -> Meteor.users.findOne(Session.get('currentBillHistory')?.seller)?.profile ? 'skyReset'

scope.paymentsDeliverySelectOptions =
  query: (query) -> query.callback
    results: Enums.DeliveryTypes
    text: '_id'
  initSelection: (element, callback) -> callback findDeliveryTypes(Session.get('currentBillHistory')?.paymentsDelivery)
  formatSelection: formatDefaultSearch
  formatResult: formatDefaultSearch
  placeholder: 'CHỌN SẢN PTGD'
  minimumResultsForSearch: -1
  readonly: -> !User.hasManagerRoles()
  changeAction: (e) -> scope.currentBillHistory.changePaymentsDelivery(e.added._id)
  reactiveValueGetter: -> findDeliveryTypes(Session.get('currentBillHistory')?.paymentsDelivery)

scope.paymentMethodSelectOptions =
  query: (query) -> query.callback
    results: Enums.PaymentMethods
    text: '_id'
  initSelection: (element, callback) -> callback findPaymentMethods(Session.get('currentBillHistory')?.paymentMethod)
  formatSelection: formatDefaultSearch
  formatResult: formatDefaultSearch
  placeholder: 'CHỌN SẢN PTGD'
  minimumResultsForSearch: -1
  readonly: -> !User.hasManagerRoles()
  changeAction: (e) -> scope.currentBillHistory.changePaymentMethod(e.added._id)
  reactiveValueGetter: -> findPaymentMethods(Session.get('currentBillHistory')?.paymentMethod)
