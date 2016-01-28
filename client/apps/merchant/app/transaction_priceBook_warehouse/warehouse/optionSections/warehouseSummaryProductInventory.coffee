Enums = Apps.Merchant.Enums
Wings.defineHyper 'warehouseSummaryProductInventory',
  helpers:
    details: ->
      for product in @details
        importFound = Schema.imports.findOne(
          'details.product': product._id
          importType       : Enums.getValue('ImportTypes', 'inventorySuccess')
        )
        product.inventoryImport = importFound
      @details

    inventoryPrice: ->
      @inventoryImport?.details?[0]?.price

    inventoryQuantity: ->
      @inventoryImport?.details?[0]?.basicQuantity

  events:
    "click .detail-row.inventory": (event, template) ->
      Session.set("warehouseSummaryProductInventoryEditId", @_id)
