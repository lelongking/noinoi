Enums = Apps.Merchant.Enums
Wings.defineApp 'interestRateNavigationPartial',
  events:
    "click .interestRateToCustomer": (event, template) ->
      FlowRouter.go('customer')

