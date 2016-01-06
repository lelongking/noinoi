Enums = Apps.Merchant.Enums
Wings.defineApp 'importNavigationPartial',
  events:
    "click .importToProvider": (event, template) -> FlowRouter.go('provider')
    "click .importToPriceBook": (event, template) -> FlowRouter.go('priceBook')
    "click .importToProduct": (event, template) -> FlowRouter.go('product')
