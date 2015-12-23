Enums = Apps.Merchant.Enums

Wings.defineHyper 'merchantSystemOptions',
  rendered: ->
#    @ui.$editQuantity.inputmask "numeric",
#      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}

  helpers:
    orderDateAllowDelete: -> paymentsDeliverySelectOptions

formatDefaultSearch  = (item) -> "#{item.display}" if item
paymentsDeliverySelectOptions =
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