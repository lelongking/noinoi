lemon.defineApp Template.customerReturnNavigationPartial,
  events:
    "click .toHistoryReturn": (event, template) -> FlowRouter.go('/orderReturnHistory')