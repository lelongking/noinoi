Enums = Apps.Merchant.Enums
Wings.defineApp 'orderReturnNavigationPartial',
  events:
    "click .orderReturnToSale": (event, template) -> FlowRouter.go('order')

