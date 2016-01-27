Enums = Apps.Merchant.Enums
Wings.defineApp 'orderReturnNavigationPartial',
  events:
    "click .orderReturnToCustomer": (event, template) -> FlowRouter.go('customer')

