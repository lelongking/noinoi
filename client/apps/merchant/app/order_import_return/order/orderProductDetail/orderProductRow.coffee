scope = logics.sales
Wings.defineHyper 'orderProductRowEdit',
  rendered: ->
    @ui.$editQuantity.inputmask "integer",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
    @ui.$editDiscountCash.inputmask "integer",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11}
    @ui.$editPrice.inputmask "integer",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11}

    @ui.$editPrice.val Template.currentData().price
    @ui.$editQuantity.val Template.currentData().quality
    @ui.$editDiscountCash.val Template.currentData().discountCash

    @ui.$editQuantity.select()

  events:
    "click .deleteOrderDetail": (event, template) -> scope.currentOrder.removeDetail(@_id)
    "keyup": (event, template) ->
      rowId = Template.currentData()._id
      details = Template.parentData().details

      quality = Number(template.ui.$editQuantity.inputmask('unmaskedvalue'))
      if quality < 0
        quality = Math.abs(quality)
        template.ui.$editQuantity.val(quality)

      price = Number(template.ui.$editPrice.inputmask('unmaskedvalue'))
      if price < 0
        price = Math.abs(price)
        template.ui.$editPrice.val(price)

      discountCash = Number(template.ui.$editDiscountCash.inputmask('unmaskedvalue'))
      if discountCash < 0
        discountCash = Math.abs(discountCash)
        template.ui.$editDiscountCash.val(discountCash)
      else if discountCash >= Template.currentData().price
        discountCash = Template.currentData().price
        template.ui.$editDiscountCash.val(discountCash)

      if event.which is 13
        quality      = undefined if quality is Template.currentData().quality
        price        = undefined if price is Template.currentData().price
        discountCash = undefined if discountCash is Template.currentData().discountCash or discountCash > Template.currentData().price
        if price is 0 then discountCash = 0
        else if price > 0
          discountCashInstance = if discountCash isnt undefined then discountCash else Template.currentData().discountCash
          discountCash = price if price < discountCashInstance

        if quality isnt undefined or price isnt undefined or discountCash isnt undefined
          Template.parentData().editDetail(rowId, quality, discountCash, price)

        if nextRow = details.getNextBy("_id", rowId)
          Session.set("editingId", nextRow._id)
        else
          Session.set("editingId")

      else if event.which is 40  #downArrow
        Session.set("editingId", nextRow._id) if nextRow = details.getNextBy("_id", rowId)


      else if event.which is 38  #upArrow
        Session.set("editingId", previousRow._id) if previousRow = details.getPreviousBy("_id", rowId)