Enums = Apps.Merchant.Enums
Wings.defineApp 'transactionNavigationPartial',
  events:
    "click .transactionToCustomer": (event, template) -> FlowRouter.go('customer')
    "click .transactionToProvider": (event, template) -> FlowRouter.go('provider')
    "click .transactionToInterestRate": (event, template) -> FlowRouter.go('interestRate')
