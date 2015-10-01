Wings.defineApp 'priceBookNavigationPartial',
  events:
    "click .customerToSales": (event, template) ->
      if customer = Session.get("customerManagementCurrentCustomer")
        Meteor.call 'customerToSales', customer, Session.get('myProfile'), (error, result) ->
          if error then console.log error else FlowRouter.go('/sales')

    "click .customerToReturns": (event, template) ->
      if customer = Session.get("customerManagementCurrentCustomer")
        Meteor.call 'customerToReturns', customer, Session.get('myProfile'), (error, result) ->
          if error then console.log error else FlowRouter.go('/customerReturn')
