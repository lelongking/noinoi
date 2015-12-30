Enums = Apps.Merchant.Enums
Wings.defineApp 'priceBookNavigationPartial',
  events:
    "click .priceBookToProduct": (event, template) -> FlowRouter.go('product')
    "click .priceBookToSale": (event, template) -> FlowRouter.go('order')
    "click .priceBookToImport": (event, template) -> FlowRouter.go('import')
