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
          owner           : customerId
          isOwner         : 'customer'
          interestRate    : Session.get('merchant')?.interestRates?.loan ? 0
          template        : 'editInitialInterest'
          active          : 'customerInitialInterest'
          amount          : undefined
          description     : undefined
          transactionType : Enums.getValue('TransactionTypes', 'editInitialInterest')
        )
        FlowRouter.go('transaction')

    "click .customerToAddLoan": (event, template) ->
      if customerId = Session.get('mySession').currentCustomer
        Session.set('transactionDetail',
          owner           : customerId
          isOwner         : 'customer'
          interestRate    : Session.get('merchant')?.interestRates?.loan ? 0
          template        : 'createPaidTransaction'
          active          : 'customerLoanCash'
          amount          : undefined
          description     : undefined
          transactionType : Enums.getValue('TransactionTypes', 'customerLoanAmount')
        )
        FlowRouter.go('transaction')

    "click .customerToAddPay": (event, template) ->
      if customerId = Session.get('mySession').currentCustomer
        Session.set('transactionDetail',
          owner           : customerId
          isOwner         : 'customer'
          template        : 'createPaidTransaction'
          active          : 'customerPaidCash'
          amount          : undefined
          interestRate    : 0
          description     : undefined
          transactionType : Enums.getValue('TransactionTypes', 'customerPaidAmount')
        )
        FlowRouter.go('transaction')


    "click .customerToInterestRate": (event, template) ->
      FlowRouter.go('interestRate')

