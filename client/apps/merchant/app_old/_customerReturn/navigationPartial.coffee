Wings.defineApp 'customerReturnNavigationPartial',
  events:
    "click .toHistoryReturn": (event, template) -> FlowRouter.go('/orderReturnHistory')