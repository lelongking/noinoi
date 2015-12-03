scope = logics.warehouse

Wings.defineApp 'warehouseReturn',
  created: ->
    Session.set('warehouseShowReturn', true)

  helpers:
    listProductsTrade: -> scope.listProductsTrade().details
    listProductsNotTrade: -> scope.listProductsNotTrade(scope.listProductsTrade().details.length).details

    totalCostPrice: ->
      scope.listProductsTrade().totalCostPrice
    totalRevenue: ->
      scope.listProductsTrade().totalRevenue
