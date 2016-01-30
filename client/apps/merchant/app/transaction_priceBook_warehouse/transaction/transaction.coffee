Enums = Apps.Merchant.Enums
scope = logics.transactionManagement
setTime = -> Session.set('realtime-now', new Date())

customerList = {}
ownerSearch = (textSearch) ->
  transaction = Session.get('transactionDetail')
  return [] unless transaction

  selector = merchant: Merchant.getId(); options = {sort: {nameSearch: 1}}
  if(textSearch)
    regExp = Helpers.BuildRegExp(textSearch);
    selector = {$or: [
      {nameSearch: regExp, merchant: Merchant.getId()}
    ,
      {name: regExp, merchant: Merchant.getId()}
    ]}
  customerList =
    if transaction.isOwner is 'provider'
      Schema.providers.find(selector, options).fetch()
    else if transaction.isOwner is 'customer'
      Schema.customers.find(selector, options).fetch()
  customerList


findTransactionOwner = (ownerId)->
  _.findWhere(customerList, {_id: ownerId})

transactionOwnerSelect =
  query: (query) -> query.callback
    results: ownerSearch(query.term)
    text: 'name'
  initSelection: (element, callback) -> callback findTransactionOwner(Session.get('transactionDetail')?.owner)
  formatSelection: (item) -> "#{item.name}" if item
  formatResult: (item) -> "#{item.name}" if item
  id: '_id'
  placeholder: 'Chọn'
  changeAction: (e) ->
    if e.added
      transactionDetail = Session.get('transactionDetail')
      transactionDetail.owner = e.added._id
      Session.set('transactionDetail', transactionDetail)
  reactiveValueGetter: -> Session.get('transactionDetail')?.owner ? 'skyReset'



Wings.defineApp 'transaction',
  created: ->
    @timeInterval = Meteor.setInterval(setTime, 1000)
    ownerSearch('')
    self = this
    self.autorun ()->
      if !Session.get('transactionDetail')
        Session.set('transactionDetail',
          template        : 'createPaidTransaction'
          active          : 'customerPaidCash'
          isOwner         : 'customer'
          owner           : Session.get('mySession')?.currentCustomer
          transactionType : Enums.getValue('TransactionTypes', 'customerPaidAmount')
          amount          : undefined
          description     : undefined
          interestRate    : undefined
        )



      transaction = Session.get('transactionDetail')
      if transaction?.owner
        ownerSearch('')
        if transaction.isOwner is 'provider'
          owner = Schema.providers.findOne({_id: transaction.owner}) ? {}

          owner.debitCash  = (owner.initialAmount ? 0) + (owner.importAmount ? 0) + (owner.loanAmount ? 0) + (owner.returnPaidAmount ? 0) - (owner.returnAmount ? 0) - (owner.paidAmount ? 0)
          owner.amountCash = Math.abs(transaction.amount)
          if transaction.transactionType is Enums.getValue('TransactionTypes', 'providerLoanAmount')
            owner.totalCash = owner.debitCash + owner.amountCash
          else if transaction.transactionType is Enums.getValue('TransactionTypes', 'providerPaidAmount')
            owner.transactionName = 'Trả Tiền'
            owner.totalCash = owner.debitCash - owner.amountCash
          else
            owner.transactionName = 'Nợ Đầu Kỳ'

        else if transaction.isOwner is 'customer'
          owner = Schema.customers.findOne({_id: transaction.owner}) ? {}

          owner.debitCash  = (owner.initialAmount ? 0) + (owner.saleAmount ? 0) + (owner.loanAmount ? 0) + (owner.returnPaidAmount ? 0) - (owner.returnAmount ? 0) - (owner.paidAmount ? 0)
          owner.amountCash = Math.abs(transaction.amount)
          if transaction.transactionType is Enums.getValue('TransactionTypes', 'customerLoanAmount')
            owner.transactionName = 'Nhập Nợ'
            owner.totalCash = owner.debitCash + owner.amountCash
          else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customerPaidAmount')
            owner.transactionName = 'Thu Tiền'
            owner.totalCash = owner.debitCash - owner.amountCash
          else
              owner.transactionName = 'Nợ Đầu Kỳ'


        Session.set('transactionOwner', owner)
      else
        Session.set('transactionOwner')



  rendered: ->

  destroyed: ->
    Session.set('transactionCreateNew')
    Session.set('transactionDetail')
    Session.set('transactionOwner')
    Meteor.clearInterval(@timeInterval)


  helpers:
    currentOwner: -> Session.get('transactionOwner')
    currentData: -> Session.get('transactionDetail')

    isShowSelectOption: (owner)-> Session.get('transactionDetail')?.isOwner is owner
    isShowSubmit: -> Session.get('transactionDetail')?.amount > 0

    isActiveClass: (template)-> if Session.get('transactionDetail')?.active is template then 'active' else ''

    isShowCustomerSelectOption: ->
      transaction = Session.get('transactionDetail')
      if transaction and transaction.isOwner is 'customer' and transaction.active isnt 'customerInitialInterest' then 'active' else ''

    isShowProviderSelectOption: ->
      transaction = Session.get('transactionDetail')
      if transaction and transaction.isOwner is 'provider' and transaction.active isnt 'providerInitialInterest' then 'active' else ''


    ownerSelectOptions: transactionOwnerSelect




  events:
    "click .createTransaction":  (event, template) ->
      transaction = Session.get('transactionDetail')
      if transaction.transactionType isnt undefined and transaction.owner and transaction.amount > 0
        Meteor.call(
          'createTransaction'
          transaction.owner
          transaction.transactionType
          transaction.amount
          'Phieu Thu Chi'
          transaction.description
          (error, result) -> console.log error, result
        )

        currentRouter = FlowRouter.current()
        if currentRouter.oldRoute and currentRouter.oldRoute.name is 'customer' and transaction.isOwner is 'customer'
          FlowRouter.go('customer')
        else if currentRouter.oldRoute and currentRouter.oldRoute.name is 'provider' and transaction.isOwner is 'provider'
          FlowRouter.go('provider')
        else
          $("[name=transactionAmount]").val('')
          $("[name=transactionDescription]").val('')
          transaction.amount = 0
          transaction.description = ''
          Session.set('transactionDetail', transaction)

    "click .toEditInterestRate":  (event, template) ->
      transactionData = Session.get('transactionDetail')
      if transactionData.active isnt 'interestRateManager'
        transactionData.template    = 'interestRateManager'
        transactionData.active      = 'interestRateManager'
        transactionData.isOwner     = ''
        transactionData.owner       = ''
        transactionData.amount      = undefined
        transactionData.description = undefined
        transactionData.interestRate= undefined
        Session.set('transactionDetail', transactionData)

    "click .toCustomerEditInitialInterest":  (event, template) ->
      transactionData = Session.get('transactionDetail')
      if transactionData.active isnt 'customerInitialInterest'
        transactionData.template        = 'editInitialInterest'
        transactionData.active          = 'customerInitialInterest'
        transactionData.isOwner         = 'customer'
        transactionData.owner           = ''
        transactionData.amount          = undefined
        transactionData.description     = undefined
        transactionData.interestRate    = Session.get('merchant')?.interestRates?.loan ? 0
        transactionData.transactionType = Enums.getValue('TransactionTypes', 'editInitialInterest')
        Session.set('transactionDetail', transactionData)
        Session.set("editInitialInterestSearchOwner")
        Session.set("editInitialInterestOwnerSearchText",'')

    "click .toCustomerAddLoanCash":  (event, template) ->
      transactionData = Session.get('transactionDetail')
      if transactionData.active isnt 'customerLoanCash'
        transactionData.template        = 'createPaidTransaction'
        transactionData.active          = 'customerLoanCash'
        transactionData.isOwner         = 'customer'
        transactionData.owner           = Session.get('mySession')?.currentCustomer ? ''
        transactionData.amount          = undefined
        transactionData.description     = undefined
        transactionData.interestRate    = Session.get('merchant')?.interestRates?.loan ? 0
        transactionData.transactionType = Enums.getValue('TransactionTypes', 'customerLoanAmount')
        Session.set('transactionDetail', transactionData)

    "click .toCustomerAddPaidCash":  (event, template) ->
      transactionData = Session.get('transactionDetail')
      if transactionData.active isnt 'customerPaidCash'
        transactionData.template        = 'createPaidTransaction'
        transactionData.active          = 'customerPaidCash'
        transactionData.isOwner         = 'customer'
        transactionData.owner           = Session.get('mySession')?.currentCustomer ? ''
        transactionData.amount          = undefined
        transactionData.description     = undefined
        transactionData.interestRate    = Session.get('merchant')?.interestRates?.loan ? 0
        transactionData.transactionType = Enums.getValue('TransactionTypes', 'customerPaidAmount')
        Session.set('transactionDetail', transactionData)

    "click .toProviderEditInitialInterest":  (event, template) ->
      transactionData = Session.get('transactionDetail')
      if transactionData.active isnt 'providerInitialInterest'
        transactionData.template        = 'editInitialInterest'
        transactionData.active          = 'providerInitialInterest'
        transactionData.isOwner         = 'provider'
        transactionData.owner           = ''
        transactionData.transactionType = Enums.getValue('TransactionTypes', 'editInitialInterest')
        transactionData.amount          = undefined
        transactionData.description     = undefined
        transactionData.interestRate    = Session.get('merchant')?.interestRates?.loan ? 0
        Session.set('transactionDetail', transactionData)
        Session.set("editInitialInterestSearchOwner")
        Session.set("editInitialInterestOwnerSearchText",'')

    "click .toProviderAddPaidCash":  (event, template) ->
      transactionData = Session.get('transactionDetail')
      if transactionData.active isnt 'providerPaidCash'
        transactionData.template        = 'createPaidTransaction'
        transactionData.active          = 'providerPaidCash'
        transactionData.isOwner         = 'provider'
        transactionData.owner           = Session.get('mySession')?.currentProvider ? ''
        transactionData.amount          = undefined
        transactionData.description     = undefined
        transactionData.interestRate    = Session.get('merchant')?.interestRates?.loan ? 0
        transactionData.transactionType = Enums.getValue('TransactionTypes', 'providerPaidAmount')
        Session.set('transactionDetail', transactionData)