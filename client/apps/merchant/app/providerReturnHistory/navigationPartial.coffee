lemon.defineApp Template.providerReturnHistoryNavigationPartial,
  events:
    "click .toProviderReturn": (event, template) -> FlowRouter.go('/providerReturn')