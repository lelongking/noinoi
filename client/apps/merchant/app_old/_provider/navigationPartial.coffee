Wings.defineApp 'providerManagementNavigationPartial',
  events:
    "click .providerOldDebt": (event, template) ->
      oldDebt = Session.get("providerManagementOldDebt")
      if oldDebt is true
        Session.set("providerManagementOldDebt")
      else
        Session.set("providerManagementOldDebt", true)
      
    "click .providerPaid": (event, template) ->
      oldDebt = Session.get("providerManagementOldDebt")
      if oldDebt is false
        Session.set("providerManagementOldDebt")
      else
        Session.set("providerManagementOldDebt", false)

    "click .providerToImport": (event, template) ->
      if provider = Session.get("providerManagementCurrentProvider")
        Meteor.call 'providerToImport', provider._id, (error, result) ->
          if error then console.log error else FlowRouter.go('/import')