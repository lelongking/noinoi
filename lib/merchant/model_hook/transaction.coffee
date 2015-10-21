Enums = Apps.Merchant.Enums

Schema.transactions.before.insert (userId, transaction)->
  console.log 'transactions before insert'


Schema.transactions.after.insert (userId, transaction) ->
  console.log 'transactions after insert'

#  if transaction.transactionGroup is Enums.getValue('TransactionGroups', 'customer')

#    console.log transactionUpdate, transactionInsert.changeBalance
#      transactionUpdate.$inc.totalCash =
#        (transactionUpdate.$inc.paidRequiredCash + transactionUpdate.$inc.paidBeginCash + transactionUpdate.$inc.paidIncurredCash +
#          transactionUpdate.$inc.paidSaleCash + transactionUpdate.$inc.returnSaleCash -
#          transactionUpdate.$inc.debtIncurredCash - transactionUpdate.$inc.debtSaleCash) ? 0
#    Schema.customers.update transaction._id, transactionUpdate
#    Schema.customerGroups.update transaction.group, $inc:{totalCash: transactionUpdate.$inc.totalCash} if transaction.group



Schema.transactions.before.update (userId, transaction, fieldNames, modifier, options) ->
  console.log 'transaction before update'


Schema.transactions.after.update (userId, newCustomer, fieldNames, modifier, options) ->
  console.log 'transaction after update'



Schema.transactions.before.remove (userId, transaction) ->
  console.log 'transaction before remove'

Schema.transactions.after.remove (userId, doc)->
  console.log 'transaction after remove'
