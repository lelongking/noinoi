Wings.defineApp 'providerNavigationPartial',
  events:
    "click .providerToImport": (event, template) ->
      if providerId = Session.get('mySession').currentProvider
        Meteor.call 'providerToImport', providerId, (error, result) ->
          if error then console.log error else FlowRouter.go('import')

    "click .providerToReturn": (event, template) ->
      if providerId = Session.get('mySession').currentProvider
        Meteor.call 'providerToReturn', providerId, (error, result) ->
          if error then console.log error else FlowRouter.go('importReturn')

    "click .providerPaid": (event, template) ->
    "click .providerOldDebt": (event, template) ->
