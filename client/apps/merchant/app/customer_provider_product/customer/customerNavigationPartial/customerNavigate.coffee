Enums = Apps.Merchant.Enums
Wings.defineApp 'customerManagementNavigationPartial',
  events:
    "click .customerToSales": (event, template) ->
      if customerId = Session.get('mySession').currentCustomer
        Meteor.call 'customerToOrder', customerId, (error, result) ->
          if error then console.log error else FlowRouter.go('order')

    "click .customerToReturn": (event, template) ->
      if customerId = Session.get('mySession').currentCustomer
        Meteor.call 'customerToReturn', customerId, (error, result) ->
          if error then console.log error else FlowRouter.go('orderReturn')

    "click .customerToAddDebt": (event, template) ->
      if customerId = Session.get('mySession').currentCustomer
        Session.set('transactionDetail',
          active: 'loan'
          group: 0
          transactionType: Enums.getValue('TransactionTypes', 'customerLoanAmount')
          name: undefined
          amount: 0
          description: undefined
          interestRate: 0
          owner: customerId
        )
        FlowRouter.go('transaction')

    "click .customerToAddPay": (event, template) ->
      if customerId = Session.get('mySession').currentCustomer
        Session.set('transactionDetail',
          active: 'paid'
          group: 0
          transactionType: Enums.getValue('TransactionTypes', 'customerPaidAmount')
          name: undefined
          amount: 0
          description: undefined
          interestRate: 0
          owner: customerId
        )
        FlowRouter.go('transaction')