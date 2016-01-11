scope = logics.priceBook

Wings.defineHyper 'customerPriceBookDetailSection',
  helpers:
    isGroup: ->
      Template.currentData().priceBookType is 2

    isSearch: -> Session.get("customerGroupDetailSectionSearchProduct")

    allProductUnits: ->
      findAllProductUnits(@)

    productSelected: ->
      productUnitSelected = Session.get('mySession').productUnitSelected["#{Template.parentData()._id}"]
      if _.contains(productUnitSelected, @_id) then 'selected' else ''

    selectAll: ->
      if priceBook = Template.currentData()
        checkProductSelect = priceBook?.products?.length is Session.get('mySession').productUnitSelected?[priceBook._id]?.length
      if priceBook?.products?.length > 0 and checkProductSelect then '#2e8bcc' else '#d8d8d8'

  events:
    "click .detail-row:not(.selected) td.command": (event, template) ->
      Template.currentData().selectedPriceProduct(@_id)

    "click .detail-row.selected td.command": (event, template) ->
      Template.currentData().unSelectedPriceProduct(@_id)

    "click .deleteUnitPrice": (event, template) ->
      Template.currentData().deletePriceOfProduct(@_id)
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

      product.basicSaleDebt    = productPriceBook.basicSaleDebt
      product.saleDebtPrice    = productPriceBook.saleDebtPrice
      product.saleDebtDiscount = productPriceBook.basicSaleDebt - productPriceBook.saleDebtPrice

      product.basicImport    = productPriceBook.basicImport
      product.importPrice    = productPriceBook.importPrice
      product.importDiscount = productPriceBook.basicImport - productPriceBook.importPrice

      productLists.push(product)


  productSearchText = Session.get('customerPriceBookDetailSectionSearchProduct')
  if productSearchText?.length > 0
    _.filter productLists, (product) ->
      unsignedTerm = Helpers.RemoveVnSigns productSearchText
      unsignedName = Helpers.RemoveVnSigns product.name
      unsignedName.indexOf(unsignedTerm) > -1
  else
    productLists













