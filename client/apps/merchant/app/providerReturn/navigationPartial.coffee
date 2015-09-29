lemon.defineApp Template.providerReturnNavigationPartial,
  events:
    "click .toHistoryReturn": (event, template) -> FlowRouter.go('/providerReturnHistory')