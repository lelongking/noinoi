Wings.defineApp 'productGroupNavigationPartial',
  events:
    "click .productToSales": (event, template) ->
      if product = Session.get("productGroupCurrentCustomer")
        Meteor.call 'productToSales', product, Session.get('myProfile'), (error, result) ->
          if error then console.log error else FlowRouter.go('/sales')

    "click .productToReturns": (event, template) ->
      if product = Session.get("productGroupCurrentCustomer")
        Meteor.call 'productToReturns', product, Session.get('myProfile'), (error, result) ->
          if error then console.log error else FlowRouter.go('/productReturn')
