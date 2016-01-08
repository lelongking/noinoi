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

    "click .providerOldDebt": (event, template) ->
      if providerId = Session.get('mySession').currentProvider
        Session.set('transactionDetail',
          active: 'paid'
          group: 1
          transactionType: Enums.getValue('TransactionTypes', 'providerLoanAmount')
          name: undefined
          amount: 0
          description: undefined
          interestRate: 0
          owner: providerId
        )
        FlowRouter.go('transaction')

    "click .providerPaid": (event, template) ->
      if providerId = Session.get('mySession').currentProvider
        Session.set('transactionDetail',
          active: 'loan'
          group: 1
          transactionType: Enums.getValue('TransactionTypes', 'providerPaidAmount')
          name: undefined
          amount: 0
          description: undefined
          interestRate: 0
          owner: providerId
        )
        FlowRouter.go('transaction')