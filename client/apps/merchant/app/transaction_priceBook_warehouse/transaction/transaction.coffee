Enums = Apps.Merchant.Enums
scope = logics.transactionManagement


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
    if transaction.group
      Schema.providers.find(selector, options).fetch()
    else
      Schema.customers.find(selector, options).fetch()
  customerList

findTransactionGroup = (transactionGroup) ->
  _.findWhere(Enums.TransactionGroups, {_id: transactionGroup})


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
  placeholder: 'Chọn KH hoặc NCC'
  changeAction: (e) ->
    if e.added
      transactionDetail = Session.get('transactionDetail')
      transactionDetail.owner = e.added._id
      Session.set('transactionDetail', transactionDetail)
  reactiveValueGetter: -> Session.get('transactionDetail')?.owner ? 'skyReset'


transactionTypeSelect =
  query: (query) -> query.callback
    results: _.filter(Enums.TransactionGroups, (num) -> return num unless num._id is 2)
    text: '_id'
  initSelection: (element, callback) -> callback findTransactionGroup(Session.get('transactionDetail')?.group)
  formatSelection: (item)-> "#{item.display}" if item
  formatResult: (item)-> "#{item.display}" if item
  placeholder: 'Chọn KH Hoặc NCC'
  minimumResultsForSearch: -1
  changeAction: (e) ->
    if e.added
      newTransaction = Session.get('transactionDetail')
      newTransaction.group = e.added._id
      delete newTransaction.owner
      Session.set('transactionDetail', newTransaction)
  reactiveValueGetter: -> findTransactionGroup(Session.get('transactionDetail')?.group)



Wings.defineApp 'transaction',
  created: ->
    ownerSearch('')
    self = this
    self.autorun ()->
      transaction = Session.get('transactionDetail')
      if transaction?.owner
        if transaction.group
          owner = Schema.providers.findOne({_id: transaction.owner}) ? {}

          owner.debitCash  = (owner.initialAmount ? 0) + (owner.importAmount ? 0) + (owner.loanAmount ? 0) + (owner.returnPaidAmount ? 0) - (owner.returnAmount ? 0) - (owner.paidAmount ? 0)
          owner.amountCash = Math.abs(transaction.amount)
          if transaction.transactionType is Enums.getValue('TransactionTypes', 'providerLoanAmount')
            owner.totalCash = owner.debitCash + owner.amountCash
          else if transaction.transactionType is Enums.getValue('TransactionTypes', 'providerPaidAmount')
            owner.totalCash = owner.debitCash - owner.amountCash

        else
          owner = Schema.customers.findOne({_id: transaction.owner}) ? {}

          owner.debitCash  = (owner.initialAmount ? 0) + (owner.saleAmount ? 0) + (owner.loanAmount ? 0) + (owner.returnPaidAmount ? 0) - (owner.returnAmount ? 0) - (owner.paidAmount ? 0)
          owner.amountCash = Math.abs(transaction.amount)
          if transaction.transactionType is Enums.getValue('TransactionTypes', 'customerLoanAmount')
            owner.totalCash = owner.debitCash + owner.amountCash
          else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customerPaidAmount')
            owner.totalCash = owner.debitCash - owner.amountCash

        Session.set('transactionOwner', owner)
      else
        Session.set('transactionOwner')

    if !Session.get('transactionDetail')
      Session.set('transactionDetail',
        active: 'interest'
        group: 0
        transactionType: Enums.getValue('TransactionTypes', 'customerLoanAmount')
        name: undefined
        amount: 0
        description: undefined
        interestRate: 0
        owner: undefined
      )

  rendered: ->

  destroyed: ->
    Session.set('transactionShowHistory')
    Session.set('transactionDetail')
    Session.set('transactionOwner')


  helpers:
    currentData: -> Session.get('transactionDetail')
    isActive: (transaction)-> if @active is transaction then 'active' else ''

    isShowDetail: (transaction)-> if @active is transaction then true else false

    ownerSelectOptions: transactionOwnerSelect
    typeSelectOptions: transactionTypeSelect
    currentCustomer: -> Session.get('transactionOwner')

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

        $("[name=transactionAmount]").val('')
        $("[name=transactionDescription]").val('')
        transaction.amount = 0
        transaction.description = ''
        Session.set('transactionDetail', transaction)

    "click .group-nav .caption.toInterest":  (event, template) ->
      transactionData = Session.get('transactionDetail')
      transactionData.active = 'interest'
      Session.set('transactionDetail', transactionData)

    "click .group-nav .caption.toLoan":  (event, template) ->
      transactionData = Session.get('transactionDetail')
      transactionData.active = 'loan'
      if transactionData.group
        transactionData.transactionType = Enums.getValue('TransactionTypes', 'providerLoanAmount')
      else
        transactionData.transactionType = Enums.getValue('TransactionTypes', 'customerLoanAmount')
      Session.set('transactionDetail', transactionData)


    "click .group-nav .caption.toPaid":  (event, template) ->
      transactionData = Session.get('transactionDetail')
      transactionData.active = 'paid'
      if transactionData.group
        transactionData.transactionType = Enums.getValue('TransactionTypes', 'providerPaidAmount')
      else
        transactionData.transactionType = Enums.getValue('TransactionTypes', 'customerPaidAmount')
      Session.set('transactionDetail', transactionData)



