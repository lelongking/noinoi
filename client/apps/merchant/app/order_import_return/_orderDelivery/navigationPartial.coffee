Wings.defineApp 'orderDeliveryNavigationPartial',
  events:
    "click .orderDeliveryToOrder": (event, template) -> FlowRouter.go('order')