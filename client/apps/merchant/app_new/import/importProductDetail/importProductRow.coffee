scope = logics.import
Wings.defineHyper 'importProductRowEdit',
  helpers:
    detailFinalPrice: -> @quality * @conversion * (@price - @discountCash)

  rendered: ->
    @ui.$editExpireDate.inputmask("dd/mm/yyyy")
    @ui.$editImportQuantity.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
    @ui.$editProductPrice.inputmask "numeric",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}

    @ui.$editImportQuantity.val Template.currentData().quality
    @ui.$editProductPrice.val Template.currentData().price
    @ui.$editExpireDate.val if Template.currentData().expire then moment(Template.currentData().expire).format('DDMMYYYY')

    if Template.currentData().expire
      @ui.$editImportQuantity.select()
    else
      @ui.$editExpireDate.select()

  events:
    "keyup": (event, template) ->
      rowId = Template.currentData()._id
      details = Template.parentData().details

      quality = Number(template.ui.$editImportQuantity.inputmask('unmaskedvalue'))
      if quality < 0
        quality = Math.abs(quality)
        template.ui.$editImportQuantity.val(quality)

      price = Number(template.ui.$editProductPrice.inputmask('unmaskedvalue'))
      if price < 0
        price = Math.abs(price)
        template.ui.$editProductPrice.val(price)

      $expireDate = template.ui.$editExpireDate.inputmask('unmaskedvalue')
      isValidDate = $expireDate.length is 8 and moment($expireDate, 'DD/MM/YYYY').isValid()
      if isValidDate then expireDate = moment($expireDate, 'DD/MM/YYYY')._d else expireDate = undefined


      if event.which is 13
        quality      = undefined if quality is Template.currentData().quality
        price        = undefined if price is Template.currentData().price
        discountCash = undefined if discountCash is Template.currentData().discountCash

        if quality isnt undefined or discountCash isnt undefined or price isnt undefined or expireDate isnt undefined
          Template.parentData().editImportDetail(rowId, quality, expireDate, discountCash, price)

        if nextRow = details.getNextBy("_id", rowId)
          Session.set("editingId", nextRow._id)
        else
          Session.set("editingId")

      else if event.which is 40  #downArrow
        Session.set("editingId", nextRow._id) if nextRow = details.getNextBy("_id", rowId)

      else if event.which is 38  #upArrow
        Session.set("editingId", previousRow._id) if previousRow = details.getPreviousBy("_id", rowId)

Wings.defineHyper 'importProductRowDisplay',
  helpers:
    detailFinalPrice: -> @quality * @conversion * (@price - @discountCash)