scope = logics.priceBook
Wings.defineHyper 'priceBookCustomerDetailRowEdit',
  helpers:
    isGroup: -> Session.get("currentPriceBook").priceBookType is 2

  rendered: ->
    @ui.$editSaleQuantity.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11, rightAlign: false}
    @ui.$editSaleQuantity.val Template.currentData().salePrice

    @ui.$editSaleQuantity.select()

  events:
    "keyup": (event, template) ->
      product = Template.currentData()
      salePrice = Math.abs(Helpers.Number(template.ui.$editSaleQuantity.inputmask('unmaskedvalue')))
      salePrice = undefined if salePrice is product.salePrice

      if event.which is 13
        console.log salePrice
        scope.currentPriceBook.updatePriceOfProduct(product._id, salePrice) if salePrice isnt undefined
        Session.set("editingId")
