lemon.defineApp Template.salesNavigationPartial,
  events:
    "click .saleToCustomer": (event, template) -> FlowRouter.go('/customer') if Meteor.userId()
    "click .saleToProduct": (event, template) -> FlowRouter.go('/product') if Meteor.userId()
    "click .saleToReturn": (event, template) -> FlowRouter.go('/customerReturn') if Meteor.userId()

