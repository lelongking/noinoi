Enums = Apps.Merchant.Enums
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

    "click .providerOldDebt ": (event, template) ->
      if providerId = Session.get('mySession').currentProvider
        Session.set('transactionDetail',
          isOwner         : 'provider'
          owner           : providerId
          template        : 'editInitialInterest'
          active          : 'providerInitialInterest'
          amount          : undefined
          description     : undefined
          transactionType : Enums.getValue('TransactionTypes', 'editInitialInterest')
        )
        FlowRouter.go('transaction')

    "click .providerPaid": (event, template) ->
      if providerId = Session.get('mySession').currentProvider
        Session.set('transactionDetail',
          isOwner         : 'provider'
          owner           : providerId
          template        : 'createPaidTransaction'
          active          : 'providerPaidCash'
          amount          : undefined
          description     : undefined
          transactionType : Enums.getValue('TransactionTypes', 'providerPaidAmount')
        )
        FlowRouter.go('transaction')