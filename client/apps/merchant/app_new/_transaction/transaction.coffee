Enums = Apps.Merchant.Enums
scope = logics.transactionManagement

Wings.defineApp 'transaction',
  created: ->
    self = this
    self.autorun ()->
      transaction = Session.get('transactionDetail')
      if transaction?.owner
        owner = Schema.customers.findOne(transaction.owner)
        owner.requiredCash = (owner.debtRequiredCash ? 0) - (owner.paidRequiredCash ? 0)
        owner.beginCash    = (owner.debtBeginCash ? 0) - (owner.paidBeginCash ? 0)
        owner.saleCash     = (owner.debtSaleCash ? 0) - (owner.paidSaleCash ? 0) - (owner.returnSaleCash ? 0)
        owner.incurredCash = (owner.debtIncurredCash ? 0) - (owner.paidIncurredCash ? 0)
        owner.totalCash    = owner.requiredCash + owner.beginCash + owner.saleCash + owner.incurredCash
        Session.set('transactionOwner', owner)
      else
        Session.set('transactionOwner')

    Session.set('transactionDetail',
      transactionGroup: Enums.getValue('TransactionGroups', 'customer')
      transactionType: Enums.getValue('TransactionTypes', 'saleCash')
      incomeOrCost: Enums.getValue('TransactionCustomerIncomeOrCost', 'saleCash')
      receivable: false
      amount: 0
      description: ''
    )

    transactionManagement =
      content: 'createTransactionSection'
      active: 'interest'
      data:
        transactionGroup: Enums.getValue('TransactionGroups', 'customer')
        transactionType: Enums.getValue('TransactionTypes', 'saleCash')
        incomeOrCost: Enums.getValue('TransactionCustomerIncomeOrCost', 'saleCash')
        receivable: false
        amount: 0
        description: ''

    Session.set('transactionManagement', transactionManagement)



  rendered: ->

  destroyed: ->
    Session.set('transactionShowHistory')
    Session.set('transactionDetail')
    Session.set('transactionOwner')


  helpers:
    currentData: -> Session.get('transactionManagement')
    isActive: (transaction)-> if @active is transaction then 'active' else ''

    isShowDetail: (transaction)-> if @active is transaction then true else false


    typeSelectOptions: scope.transactionTypeSelect
    ownerSelectOptions: scope.transactionOwnerSelect
    customerIncomeOrCostSelectOptions: scope.transactionOwnerIncomeOrCostSelect


  events:
    "click .createTransaction":  (event, template) ->
      $payDescription = template.ui.$transactionDescription
      $payAmount      = template.ui.$transactionAmount
      transaction     = Session.get('transactionDetail')

      if transaction.transactionType isnt undefined and
        transaction.receivable isnt undefined and
        transaction.owner and
        transaction.amount > 0 and
        transaction.description.length > 0

          Meteor.call(
            'createNewTransaction'
            Enums.getValue('TransactionGroups', 'customer')
            transaction.transactionType
            transaction.receivable

            transaction.owner
            transaction.amount
            transaction.description
            (error, result) -> console.log error, result
          )

          $payDescription.val(''); $payAmount.val('')
          transaction.amount = 0
          Session.set('transactionDetail', transaction)

    "click .group-nav .caption.toInterest":  (event, template) ->
      transactionData = Session.get('transactionManagement')
      transactionData.active = 'interest'
      Session.set('transactionManagement', transactionData)

    "click .group-nav .caption.toLoan":  (event, template) ->
      transactionData = Session.get('transactionManagement')
      transactionData.active = 'loan'
      Session.set('transactionManagement', transactionData)


    "click .group-nav .caption.toPaid":  (event, template) ->
      transactionData = Session.get('transactionManagement')
      transactionData.active = 'paid'
      Session.set('transactionManagement', transactionData)


transactionOwnerSelect:
  query: (query) -> query.callback
    results: ownerSearch(query.term)
    text: 'name'
  initSelection: (element, callback) -> callback findTransactionOwner(Session.get('transactionManagement')?.data.owner)
  formatSelection: (item) -> "#{item.name}" if item
  formatResult: (item) -> "#{item.name}" if item
  id: '_id'
  placeholder: 'Chọn KH hoặc NCC'
  changeAction: (e) ->
    if e.added
      transactionManagement = Session.get('transactionManagement')
      newTransaction = transactionManagement.data
      newTransaction.owner = e.added._id
      Session.set('transactionManagement', transactionManagement)
  reactiveValueGetter: -> Session.get('transactionManagement')?.data.owner ? 'skyReset'



customerList = {}
ownerSearch = (textSearch) ->
  transaction = Session.get('transactionDetail')
  return [] unless transaction

  selector = merchant: Merchant.getId(); options = {sort: {nameSearch: 1}}
  if(textSearch)
    regExp = Helpers.BuildRegExp(textSearch);
    selector = {$or: [
      {nameSearch: regExp, merchant: Merchant.getId()}
    ]}
  customerList = Schema.customers.find(selector, options).fetch()
  customerList

findTransactionGroup = (transactionGroup) ->
  _.findWhere(Enums.TransactionGroups, {_id: transactionGroup})

findTransactionReceivable = (receivable) ->
  _.findWhere(Enums.TransactionCustomerIncomeOrCost, {_id: receivable})

findTransactionOwner = (ownerId)->
  _.findWhere(customerList, {_id: ownerId})







































numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: "%/tháng", integerDigits:4, rightAlign: false}
Wings.defineHyper 'interestRateManager',
  created: ->

  rendered: ->
    self = this
    self.ui.$interestRateInitial.inputmask "decimal", numericOption
    self.ui.$interestRateInitial.val 2

    self.ui.$interestRateLoan.inputmask "decimal", numericOption
    self.ui.$interestRateLoan.val 2

    self.ui.$interestRateSale.inputmask "decimal", numericOption
    self.ui.$interestRateSale.val 2

Wings.defineHyper 'editInitialInterest',
  created: ->

  rendered: ->
    self = this
    self.ui.$initialAmount.inputmask "integer", {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: "", integerDigits: 11, rightAlign: false}
    self.ui.$initialAmount.val 50000

    self.ui.$initialInterestRate.inputmask "decimal", {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: "%/tháng", integerDigits:4, rightAlign: false}
    self.ui.$initialInterestRate.val 2

    dateOfBirth = moment().format("DD/MM/YYYY")
    @datePicker.$dateDebit.datepicker('setDate', dateOfBirth)
