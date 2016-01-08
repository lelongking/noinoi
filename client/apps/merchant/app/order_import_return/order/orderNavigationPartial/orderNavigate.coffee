Enums = Apps.Merchant.Enums
Wings.defineApp 'orderNavigationPartial',
  events:
    "click .orderToDelivery": (event, template) -> FlowRouter.go('billManager')
    "click .orderToCustomer": (event, template) -> FlowRouter.go('customer')
    "click .orderToPriceBook": (event, template) -> FlowRouter.go('priceBook')
    "click .orderToProduct": (event, template) -> FlowRouter.go('product')
