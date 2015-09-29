lemon.defineApp Template.customerReturnHistoryNavigationPartial,
  events:
    "click .toCustomerReturn": (event, template) -> FlowRouter.go('/customerReturn')