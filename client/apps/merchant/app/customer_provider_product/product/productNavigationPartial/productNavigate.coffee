Enums = Apps.Merchant.Enums
Wings.defineApp 'productManagementNavigationPartial',
  events:
    "click .productToPriceBook": (event, template) -> FlowRouter.go('priceBook')
    "click .productToOrder": (event, template) -> FlowRouter.go('order')
