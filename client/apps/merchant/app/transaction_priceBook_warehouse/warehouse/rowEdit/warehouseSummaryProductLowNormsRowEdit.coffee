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


Wings.defineHyper 'warehouseSummaryProductInventoryEdit',
  rendered: ->
    @ui.$importPrice?.inputmask "integer",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits: 11, rightAlign: true, suffix: " VNĐ"}
    @ui.$importPrice?.val Template.currentData().inventoryImport?.details?[0]?.price


    @ui.$importQuality?.inputmask "integer",
      {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits: 5, rightAlign: true}
    @ui.$importQuality?.val Template.currentData().inventoryImport?.details?[0]?.basicQuantity ? ''

    @ui.$importQuality?.select()

  events:
    "keyup input[name='importPrice']": (event, template) ->
      product = @
      importPrice = parseInt(template.ui.$importPrice.inputmask('unmaskedvalue'))
      if product.inventoryInitial
        Helpers.deferredAction ->
          if !isNaN(importPrice) and product.inventoryImport and importPrice isnt product.inventoryImport.details[0].price
            product.inventoryImport.editImportDetail(product.inventoryImport.details[0]._id, undefined, undefined, undefined, importPrice)
        , "warehouseSectionEditInventory"
        , 200

      if event.which is 13
        Session.set("warehouseSummaryProductInventoryEditId", '')

    "keyup input[name='importQuality']": (event, template) ->
      product = @
      importQuality =  parseInt(template.ui.$importQuality.inputmask('unmaskedvalue'))
      if product.inventoryInitial
        Helpers.deferredAction ->
          if !isNaN(importQuality) and product.inventoryImport and importQuality isnt product.inventoryImport.details[0].basicQuantity
            product.inventoryImport.editImportDetail(product.inventoryImport.details[0]._id, importQuality)

            quantityChange = importQuality - product.importInventory
            productUpdate =
              $set:
                importInventory: importQuality
              $inc:
                'merchantQuantities.0.availableQuantity' : quantityChange
                'merchantQuantities.0.inStockQuantity'   : quantityChange
                'merchantQuantities.0.importQuantity'    : quantityChange
            Schema.products.update product._id, productUpdate
        , "warehouseSectionEditInventory"
        , 200
      else
        if !isNaN(importQuality)
          importDetail = {quantity: importQuality, product: product._id}
          Meteor.call 'productInventory', product._id, importDetail, (error, result) -> console.log error, result

      if event.which is 13
        Session.set("warehouseSummaryProductInventoryEditId", '')