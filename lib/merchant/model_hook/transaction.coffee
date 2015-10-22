Enums = Apps.Merchant.Enums

#---------After-Remove-------------------------------------------------------------------------------------------------
calculateTotalBalance = (balance)->
  balance.debtIncurredCash - balance.paidIncurredCash - balance.paidRequiredCash +
    balance.debtSaleCash - balance.paidSaleCash - balance.returnSaleCash - balance.paidBeginCash

updateTransactionAndOwner = (transaction)->
  beforeBalance = transaction.beforeBalance
  latestBalance = _.clone(beforeBalance)

  findBeforeTransaction = Schema.transactions.findOne({
    owner              : transaction.owner
    isRoot             : true
    'version.createdAt': {$lt: transaction.version.createdAt}
  }) if transaction.parent

  Schema.transactions.find({
    owner               : transaction.owner
    transactionGroup    : transaction.transactionGroup
    'version.createdAt' : {$gt: transaction.version.createdAt}
  }
  , {sort: {'version.createdAt': 1}}).forEach((item) ->
    balanceBefore = calculateTotalBalance(beforeBalance)
    latestBalance[key] += value for key, value of item.changeBalance
    balanceLatest = calculateTotalBalance(latestBalance)

    transactionUpdate =
      $set:
        balanceBefore: balanceBefore
        balanceLatest: balanceLatest

        beforeBalance: beforeBalance
        latestBalance: latestBalance


    if transaction.parent and transaction.isRoot and transaction.parent is item.parent
      if findBeforeTransaction
        transactionUpdate.$set.parent = findBeforeTransaction.parent
      else
        transactionUpdate.$unset = {parent: ""}

    Schema.transactions.direct.update item._id, transactionUpdate
    beforeBalance = latestBalance
  )


  updateAllowDelete = {}; updateInc = {}
  updateAllowDelete.allowDelete = Schema.transactions.find({owner: transaction.owner}).count() is 0
  updateInc[key] = -value for key, value of transaction.changeBalance

  if transaction.transactionGroup is Enums.getValue('TransactionGroups', 'customer')
    Schema.customers.update(transaction.owner, {$inc: updateInc, $set: updateAllowDelete})

  else if transaction.transactionGroup is Enums.getValue('TransactionGroups', 'provider')
    Schema.providers.update(transaction.owner, {$inc: updateInc, $set: updateAllowDelete})

#---------Before-Insert-------------------------------------------------------------------------------------------------
calculateTransaction = (transaction)->
  if transaction.transactionGroup is Enums.getValue('TransactionGroups', 'customer')
    owner = Schema.customers.findOne(transaction.owner)
  else if transaction.transactionGroup is Enums.getValue('TransactionGroups', 'provider')
    owner = Schema.providers.findOne(transaction.owner)

  if owner
    transaction.beforeBalance =
      paidRequiredCash: owner.paidRequiredCash ? 0
      paidBeginCash   : owner.paidBeginCash ? 0
      debtIncurredCash: owner.debtIncurredCash ? 0
      paidIncurredCash: owner.paidIncurredCash ? 0
      debtSaleCash    : owner.debtSaleCash ? 0
      paidSaleCash    : owner.paidSaleCash ? 0
      returnSaleCash  : owner.returnSaleCash ? 0
    transaction.balanceBefore = calculateTotalBalance(transaction.beforeBalance)


    transaction.latestBalance =
      paidRequiredCash: (owner.paidRequiredCash ? 0) + (transaction.changeBalance.paidRequiredCash ? 0)
      paidBeginCash   : (owner.paidBeginCash ? 0) + (transaction.changeBalance.paidBeginCash ? 0)
      debtIncurredCash: (owner.debtIncurredCash ? 0) + (transaction.changeBalance.debtIncurredCash ? 0)
      paidIncurredCash: (owner.paidIncurredCash ? 0) + (transaction.changeBalance.paidIncurredCash ? 0)
      debtSaleCash    : (owner.debtSaleCash ? 0) + (transaction.changeBalance.debtSaleCash ? 0)
      paidSaleCash    : (owner.paidSaleCash ? 0) + (transaction.changeBalance.paidSaleCash ? 0)
      returnSaleCash  : (owner.returnSaleCash ? 0) + (transaction.changeBalance.returnSaleCash ? 0)

    transaction.balanceLatest = calculateTotalBalance(transaction.latestBalance)

#---------Before-Insert-------------------------------------------------------------------------------------------------
updateCashOfOwner = (transaction)->
  ownerUpdate =
    $set: allowDelete: false
    $inc:
      paidRequiredCash: transaction.changeBalance.paidRequiredCash
      paidBeginCash   : transaction.changeBalance.paidBeginCash
      debtIncurredCash: transaction.changeBalance.debtIncurredCash
      paidIncurredCash: transaction.changeBalance.paidIncurredCash
      debtSaleCash    : transaction.changeBalance.debtSaleCash
      paidSaleCash    : transaction.changeBalance.paidSaleCash
      returnSaleCash  : transaction.changeBalance.returnSaleCash

  if transaction.transactionGroup is Enums.getValue('TransactionGroups', 'customer')
    Schema.customers.update transaction.owner, ownerUpdate
  else if transaction.transactionGroup is Enums.getValue('TransactionGroups', 'customer')
    Schema.providers.update transaction.owner, ownerUpdate





#-----------------------------------------------------------------------------------------------------------------------
Schema.transactions.before.insert (userId, transaction)->
  calculateTransaction(transaction)

Schema.transactions.after.insert (userId, transaction) ->
  updateCashOfOwner(transaction)

#-----------------------------------------------------------------------------------------------------------------------
Schema.transactions.before.update (userId, transaction, fieldNames, modifier, options) ->

Schema.transactions.after.update (userId, newCustomer, fieldNames, modifier, options) ->


#-----------------------------------------------------------------------------------------------------------------------
Schema.transactions.before.remove (userId, transaction) ->


Schema.transactions.after.remove (userId, transaction)->
  updateTransactionAndOwner(transaction)
