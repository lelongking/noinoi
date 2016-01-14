scope = logics.sales
Wings.defineHyper 'warehouseSummaryProductLowNormsRowEdit',
  rendered: ->
    @ui.$editLowNorms.inputmask "integer",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits: 5, rightAlign: true}
    @ui.$editLowNorms.val Template.currentData().quantity.lowNormsQuantity
    @ui.$editLowNorms.select()

  events:
    "keyup input[name='editLowNorms']": (event, template) ->
      product = @
      Helpers.deferredAction ->
        productLowNorms =  parseInt(template.ui.$editLowNorms.inputmask('unmaskedvalue'))
        if !isNaN(productLowNorms) and productLowNorms isnt product.merchantQuantities[0].lowNormsQuantity
          productUpdate =
            $set:
              'merchantQuantities.0.lowNormsQuantity': productLowNorms
          Schema.products.update product._id, productUpdate , (error, result) -> if error then console.log error
      , "warehouseSectionEditLowNorms"
      , 200

      if event.which is 13
        Session.set("warehouseSummaryProductLowNormsEditId", '')