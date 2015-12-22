Enums = Apps.Merchant.Enums

formatDefaultSearch  = (item) -> "#{item.display}" if item
findPaymentMethods   = (paymentMethodId)-> _.findWhere(Enums.PaymentMethods, {_id: paymentMethodId})
findDeliveryTypes    = (deliveryTypeId)-> _.findWhere(Enums.DeliveryTypes, {_id: deliveryTypeId})
customerSearch       = (query) -> CustomerSearch.search(query.term); CustomerSearch.getData({sort: {name: 1}})



Wings.defineApp 'orderLayout',
  created: ->
  helpers:
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
      scope.currentOrder.orderConfirm()








tabOptions =
  source: -> Order.findNotSubmitted()
  currentSource: 'currentOrder'
  caption: 'orderName'
  key: '_id'
  createAction  : -> Order.insert()
  destroyAction : (instance) -> if instance then Order.findNotSubmitted().count() if instance.remove() else -1
  navigateAction: (instance) -> Order.setSession(instance._id)


debtDateOptions =
  reactiveSetter: (val) -> scope.currentOrder.changeDueDay(val)
  reactiveValue: -> Session.get('currentOrder')?.dueDay ? 0
  reactiveMax: -> 180
  reactiveMin: -> 0
  reactiveStep: -> 30
  others:
    forcestepdivisibility: 'none'


discountOptions =
  reactiveSetter: (val) -> scope.currentOrder.changeDiscountCash(val)
  reactiveValue: -> Session.get('currentOrder')?.discountCash ? 0
  reactiveMax: -> 99999999999
  reactiveMin: -> 0
  reactiveStep: -> 1000
  others:
    forcestepdivisibility: 'none'

depositOptions =
  reactiveSetter: (val) -> scope.currentOrder.changeDepositCash(val)
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
  initSelection: (element, callback) -> callback '' #Schema.customers.findOne(scope.currentOrder.buyer)
  formatSelection: (item) -> "#{item.name}" if item
  formatResult: (item) -> "#{item.name}" if item
  id: '_id'
  placeholder: 'CHỌN NGƯỜI MUA'
  changeAction: (e) -> #scope.currentOrder.changeBuyer(e.added._id)
  reactiveValueGetter: -> #Session.get('currentOrder')?.buyer ? 'skyReset'



paymentsDeliverySelectOptions =
  query: (query) -> query.callback
    results: Enums.DeliveryTypes
    text: '_id'
  initSelection: (element, callback) -> callback findDeliveryTypes(Session.get('currentOrder')?.paymentsDelivery)
  formatSelection: (item) -> "#{item.display}" if item
  formatResult: (item) -> "#{item.display}" if item
  placeholder: 'CHỌN PTGD'
  minimumResultsForSearch: -1
  changeAction: (e) -> #scope.currentOrder.changePaymentsDelivery(e.added._id)
  reactiveValueGetter: -> #findDeliveryTypes(Session.get('currentOrder')?.paymentsDelivery)


paymentMethodSelectOptions =
  query: (query) -> query.callback
    results: Enums.PaymentMethods
    text: '_id'
  initSelection: (element, callback) -> callback [] #findPaymentMethods(Session.get('currentOrder')?.paymentMethod)
  formatSelection: (item) -> "#{item.display}" if item
  formatResult: (item) -> "#{item.display}" if item
  placeholder: 'CHỌN PTGD'
  minimumResultsForSearch: -1
  changeAction: (e) -> #scope.currentOrder.changePaymentMethod(e.added._id)
  reactiveValueGetter: -> #findPaymentMethods(Session.get('currentOrder')?.paymentMethod)