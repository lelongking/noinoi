scope = logics.providerManagement
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}
Enums = Apps.Merchant.Enums

Wings.defineHyper 'providerDetailSection',
  rendered: ->
    @ui.$payImportAmount.inputmask("numeric", numericOption)

  helpers:
    allImports: ->
      console.log Template.currentData()
      findAllImport(Template.currentData())
    oldDebts: ->  findOldDebt()
    hasOldDebts: -> findOldDebt().length > 0

    isDelete: -> moment().diff(@version.createdAt ? new Date(), 'days') < 1

    totalDebtCash: ->
      if provider = Template.currentData()
        provider.debtCash + provider.loanCash
      else 0

    totalPaidCash: ->
      if provider = Template.currentData()
        (unless provider.paidCash is undefined then provider.paidCash else 0) + (unless provider.returnCash is undefined then provider.returnCash else 0)
      else 0

    transactionDescription: -> if Session.get("providerManagementOldDebt") then 'ghi chú nợ tiền' else 'ghi chú trả tiền'
    transactionStatus: -> if Session.get("providerManagementOldDebt") then 'Nợ Tiền' else 'Trả Tiền'
    showTransaction: -> if Session.get("providerManagementOldDebt") is undefined then 'display: none'

  events:
    "keyup input.transaction-field":  (event, template) ->
      scope.checkAllowCreateAndCreateTransaction(event, template)

    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id

    "click .createTransaction": (event, template) ->
      scope.createTransactionOfProvider(event, template)

findOldDebt = (currentProvider)->
  if currentProvider
    transaction = Schema.transactions.find({owner: currentProvider._id, parent:{$exists: false}}, {sort: {'version.createdAt': 1}})
    transactionCount = transaction.count(); count = 0
    transaction.map(
      (transaction) ->
        count += 1
        transaction.isLastTransaction = true if count is transactionCount
        transaction
    )
  else []




transactionFind = (parentId)->
  Schema.transactions.find({parent: parentId}, {sort: {'version.createdAt': 1}})

findAllImport = (currentProvider)->
  if currentProvider
    imports = Schema.imports.find({
      provider  : currentProvider._id
      importType: Enums.getValue('ImportTypes', 'success')
    }).map(
      (item) ->
        item.transactions = transactionFind(item._id).fetch()
        item.transactions[item.transactions.length-1].isLastTransaction = true if item.transactions.length > 0
        item
    )

    returns = Schema.returns.find({
      owner       : currentProvider._id
      returnType  : Enums.getValue('ReturnTypes', 'provider')
      returnStatus: Enums.getValue('ReturnStatus', 'success')
    }).map(
      (item) ->
        item.transactions = transactionFind(item._id).fetch()
        item.transactions[item.transactions.length-1].isLastTransaction = true if item.transactions.length > 0
        item
    )

    dataSource = _.sortBy(imports.concat(returns), (item) -> item.successDate)
    classColor = false
    for item in dataSource
      item.classColor = classColor
      classColor = !classColor
    dataSource

  else []