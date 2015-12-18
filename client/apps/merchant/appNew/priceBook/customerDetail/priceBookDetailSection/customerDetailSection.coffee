scope = logics.priceBook

Wings.defineHyper 'customerPriceBookDetailSection',
  helpers:
    isGroup: ->
      Session.get("currentPriceBook").priceBookType is 2

    allProductUnits: ->
      findAllProductUnits(@)

    productSelected: ->
      if _.contains(Session.get("priceProductLists"), @_id) then 'selected' else ''

  events:
    "click .detail-row:not(.selected) td.command": (event, template) ->
      scope.currentPriceBook.selectedPriceProduct(@_id)

    "click .detail-row.selected td.command": (event, template) ->
      scope.currentPriceBook.unSelectedPriceProduct(@_id)

    "click .deleteUnitPrice": (event, template) ->
      scope.currentPriceBook.deletePriceOfProduct(@_id)
      Session.set("editingId")

    "dblclick .detail-row": (event, template) ->
      Session.set("editingId", @_id)
      event.stopPropagation()



findAllProductUnits = (priceBook)->
  productLists = []
  lists = Schema.products.find(
    {_id: {$in: priceBook.products} ,'priceBooks._id': priceBook._id}
    {sort: {name: 1}}
  ).fetch()

  for product in lists
    productPriceBook = _.findWhere(product.priceBooks, {_id: priceBook._id})
    basicUnit = _.findWhere(product.units, {isBase: true})

    if basicUnit and productPriceBook
      product.productName     = product.name
      product.productUnitName = basicUnit.name
      product.priceBookType   = priceBook.priceBookType

      product.basicSale    = productPriceBook.basicSale
      product.salePrice    = productPriceBook.salePrice
      product.saleDiscount = productPriceBook.basicSale - productPriceBook.salePrice

      product.basicImport    = productPriceBook.basicImport
      product.importPrice    = productPriceBook.importPrice
      product.importDiscount = productPriceBook.basicImport - productPriceBook.importPrice

      productLists.push(product)

#  scope.allProductUnits = productLists
  return productLists












