Wings.defineApp 'warehouseNavigationPartial',
  events:
    "click .warehouseShowTradeProducts": (event, template) -> Session.set('warehouseShowAll', false)
    "click .warehouseShowAllProducts": (event, template) -> Session.set('warehouseShowAll', true)
    "click .warehouseShowReturns": (event, template) ->
      Session.set('warehouseShowReturn', true)
      BlazeLayout.render 'merchantLayout',
        content: 'warehouseReturn'

    "click .warehouseShow": (event, template) ->
      Session.set('warehouseShowReturn', false)
      BlazeLayout.render 'merchantLayout',
        content: 'warehouse'


