Enums = Apps.Merchant.Enums
Wings.defineApp 'importReturnNavigationPartial',
  events:
    "click .importReturnToProvider": (event, template) -> FlowRouter.go('provider')

