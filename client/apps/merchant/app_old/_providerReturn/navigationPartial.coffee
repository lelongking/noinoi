Wings.defineApp 'providerReturnNavigationPartial',
  events:
    "click .toHistoryReturn": (event, template) -> FlowRouter.go('/providerReturnHistory')