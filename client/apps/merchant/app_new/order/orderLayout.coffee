Enums = Apps.Merchant.Enums

formatDefaultSearch  = (item) -> "#{item.display}" if item
findPaymentMethods   = (paymentMethodId) -> _.findWhere(Enums.PaymentMethods, {_id: paymentMethodId})
findDeliveryTypes    = (deliveryTypeId) -> _.findWhere(Enums.DeliveryTypes, {_id: deliveryTypeId})
customerSearch       = (query) -> CustomerSearch.search(query.term); CustomerSearch.getData({sort: {name: 1}})


currentOrder = {}
Wings.defineApp 'orderLayout',
  created: ->
    self = this
    self.currentOrder = new ReactiveVar({})
    self.autorun ()->
      if currentOrderId = Session.get('mySession')?.currentOrder
        currentOrder = Schema.orders.findOne({_id: currentOrderId})
        self.currentOrder.set(currentOrder)


  rendered: ->
  destroyed: ->


  helpers:
    customerOrder: -> Template.instance().currentOrder.get()

    #header
    customerSelectOptions: -> customerSelectOptions
    paymentMethodSelectOptions: -> paymentMethodSelectOptions
    paymentsDeliverySelectOptions: -> paymentsDeliverySelectOptions

    #footer
    debtDateOptions: -> debtDateOptions
    discountOptions: -> discountOptions
    depositOptions: -> depositOptions
    tabOptions: -> tabOptions

  events:
    "click .print-command": (event, template) -> window.print()
    "click .export-command": (event, template) ->
      link = window.document.createElement('a')
      link.setAttribute 'href', '/download/order/' + Session.get("currentOrder")._id
      link.click()

    "click .finish": (event, template)->
      currentOrder.orderConfirm()



tabOptions =
  source: -> Order.findNotSubmitted()
  currentSource: 'currentOrder'
  caption: 'orderName'
  key: '_id'
  createAction  : -> Order.insert()
  destroyAction : (instance) -> if instance then Order.findNotSubmitted().count() if instance.remove() else -1
  navigateAction: (instance) -> Order.setSession(instance._id)


debtDateOptions =
  reactiveSetter: (val) -> currentOrder.changeDueDay(val)
  reactiveValue: -> Session.get('currentOrder')?.dueDay ? 0
  reactiveMax: -> 180
  reactiveMin: -> 0
  reactiveStep: -> 30
  others:
    forcestepdivisibility: 'none'


discountOptions =
  reactiveSetter: (val) -> currentOrder.changeDiscountCash(val)
  reactiveValue: -> Session.get('currentOrder')?.discountCash ? 0
  reactiveMax: -> 99999999999
  reactiveMin: -> 0
  reactiveStep: -> 1000
  others:
    forcestepdivisibility: 'none'

depositOptions =
  reactiveSetter: (val) -> currentOrder.changeDepositCash(val)
  reactiveValue: -> Session.get('currentOrder')?.depositCash ? 0
  reactiveMax: -> 99999999999
  reactiveMin: -> 0
  reactiveStep: -> 1000
  others:
    forcestepdivisibility: 'none'


customerSelectOptions =
  query: (query) -> query.callback
    results: customerSearch(query)
    text: 'name'
  initSelection: (element, callback) -> callback Schema.customers.findOne(Session.get('currentOrder')?.buyer)
  formatSelection: (item) -> "#{item.name}" if item
  formatResult: (item) -> "#{item.name}" if item
  id: '_id'
  placeholder: 'CHỌN NGƯỜI MUA'
  changeAction: (e) -> currentOrder.changeBuyer(e.added._id)
  reactiveValueGetter: -> Session.get('currentOrder')?.buyer ? 'skyReset'



paymentsDeliverySelectOptions =
  query: (query) -> query.callback
    results: Enums.DeliveryTypes
    text: '_id'
  initSelection: (element, callback) -> callback findDeliveryTypes(Session.get('currentOrder')?.paymentsDelivery)
  formatSelection: (item) -> "#{item.display}" if item
  formatResult: (item) -> "#{item.display}" if item
  placeholder: 'CHỌN PTGD'
  minimumResultsForSearch: -1
  changeAction: (e) -> currentOrder.changePaymentsDelivery(e.added._id)
  reactiveValueGetter: -> findDeliveryTypes(Session.get('currentOrder')?.paymentsDelivery)


paymentMethodSelectOptions =
  query: (query) -> query.callback
    results: Enums.PaymentMethods
    text: '_id'
  initSelection: (element, callback) -> callback findPaymentMethods(Session.get('currentOrder')?.paymentMethod)
  formatSelection: (item) -> "#{item.display}" if item
  formatResult: (item) -> "#{item.display}" if item
  placeholder: 'CHỌN PTGD'
  minimumResultsForSearch: -1
  changeAction: (e) -> currentOrder.changePaymentMethod(e.added._id)
  reactiveValueGetter: -> findPaymentMethods(Session.get('currentOrder')?.paymentMethod)