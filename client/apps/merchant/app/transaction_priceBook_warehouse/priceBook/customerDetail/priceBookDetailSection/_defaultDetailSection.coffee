scope = logics.priceBook

Wings.defineHyper 'defaultPriceBookDetailSectionHeader',
  helpers:
    selectAll: ->
      console.log Template.parentData()
      if priceBook = Template.parentData()
        checkProductSelect = priceBook?.products.length is Session.get('mySession').productUnitSelected?[priceBook._id]?.length
      if priceBook?.products.length > 0 and checkProductSelect then '#2e8bcc' else '#d8d8d8'

Wings.defineHyper 'defaultPriceBookDetailSection',
  helpers:
    isPriceBookType: (bookType)->
      priceType = Session.get("currentPriceBook").priceBookType
      return true if bookType is 'default' and priceType is 0
      return true if bookType is 'customer' and (priceType is 1 or priceType is 2)
      return true if bookType is 'provider' and (priceType is 3 or priceType is 4)

    allProductUnits: ->
      findAllProductUnits(@)

    productSelected: ->
      productUnitSelected = Session.get('mySession').productUnitSelected["#{Template.parentData()._id}"]
      if _.contains(productUnitSelected, @_id) then 'selected' else ''



  events:
    "click .detail-row:not(.selected) td.command": (event, template) ->
      Template.currentData().selectedPriceProduct(@_id)

    "click .detail-row.selected td.command": (event, template) ->
      Template.currentData().unSelectedPriceProduct(@_id)

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

      product.basicSaleDebt    = productPriceBook.basicSaleDebt
      product.saleDebtPrice    = productPriceBook.saleDebtPrice
      product.saleDebtDiscount = productPriceBook.basicSaleDebt - productPriceBook.saleDebtPrice

      product.basicImport    = productPriceBook.basicImport
      product.importPrice    = productPriceBook.importPrice
      product.importDiscount = productPriceBook.basicImport - productPriceBook.importPrice

      productLists.push(product)

  #  scope.allProductUnits = productLists
  return productLists













