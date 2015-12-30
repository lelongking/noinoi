Enums = Apps.Merchant.Enums
Wings.defineApp 'importReturnNavigationPartial',
  events:
    "click .importReturnToImport": (event, template) -> FlowRouter.go('import')

