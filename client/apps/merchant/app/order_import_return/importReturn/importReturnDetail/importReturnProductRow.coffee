scope = logics.providerReturn
Wings.defineHyper 'importReturnProductRowEdit',
  rendered: ->
    @ui.$editQuantity.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
    @ui.$editQuantity.val Template.currentData().quality

    @ui.$editPrice.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
    @ui.$editPrice.val Template.currentData().price

    @ui.$editQuantity.select()

  helpers:
    finalPrice: -> @price*@basicQuantity
    productUnitPrice: -> @price*@conversion


  events:
    "keyup": (event, template) ->
      rowId = Template.currentData()._id
      details = Template.parentData().importReturn.details
      console.log Template.currentData(), Template.parentData()

      quality = Number(template.ui.$editQuantity.inputmask('unmaskedvalue'))
      if quality < 0
        quality = Math.abs(quality)
        template.ui.$editQuantity.val(quality)

      price = Number(template.ui.$editPrice.inputmask('unmaskedvalue'))
      if price < 0
        price = Math.abs(price)
        template.ui.$editPrice.val(price)

      if event.which is 13
        discountCash = undefined if discountCash is Template.currentData().discountCash
        quality      = undefined if quality is Template.currentData().quality
        price      = undefined if price is Template.currentData().price

        if quality isnt undefined or price isnt undefined or discountCash isnt undefined
          Template.parentData().importReturn.editReturnDetail(rowId, quality, discountCash, price)

        nextRow = details.getNextBy("_id", rowId)
        Session.set("editingId", if nextRow then nextRow._id else undefined)

      else if event.which is 40  #downArrow
        Session.set("editingId", nextRow._id) if nextRow = details.getNextBy("_id", rowId)

      else if event.which is 38  #upArrow
        Session.set("editingId", previousRow._id) if previousRow = details.getPreviousBy("_id", rowId)

lemon.defineHyper Template.importReturnProductRowDisplay,
  helpers:
    finalPrice: -> @price*@basicQuantity
    productUnitPrice: -> @price*@conversion