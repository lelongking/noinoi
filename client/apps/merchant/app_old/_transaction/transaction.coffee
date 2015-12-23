#Enums = Apps.Merchant.Enums
#scope = logics.transactionManagement
#
#lemon.defineApp Template.transaction,
#  created: ->
#    self = this
#    self.autorun ()->
#      transaction = Session.get('transactionDetail')
#      if transaction?.owner
#        owner = Schema.customers.findOne(transaction.owner)
#        owner.requiredCash = (owner.debtRequiredCash ? 0) - (owner.paidRequiredCash ? 0)
#        owner.beginCash    = (owner.debtBeginCash ? 0) - (owner.paidBeginCash ? 0)
#        owner.saleCash     = (owner.debtSaleCash ? 0) - (owner.paidSaleCash ? 0) - (owner.returnSaleCash ? 0)
#        owner.incurredCash = (owner.debtIncurredCash ? 0) - (owner.paidIncurredCash ? 0)
#        owner.totalCash    = owner.requiredCash + owner.beginCash + owner.saleCash + owner.incurredCash
#        Session.set('transactionOwner', owner)
#      else
#        Session.set('transactionOwner')
#
#    Session.set('transactionDetail',
#      transactionGroup: Enums.getValue('TransactionGroups', 'customer')
#      transactionType: Enums.getValue('TransactionTypes', 'saleCash')
#      incomeOrCost: Enums.getValue('TransactionCustomerIncomeOrCost', 'saleCash')
#      receivable: false
#      amount: 0
#      description: ''
#    )
#
#    transactionManagement =
#      content: 'createTransactionSection'
#      data:
#        transactionGroup: Enums.getValue('TransactionGroups', 'customer')
#        transactionType: Enums.getValue('TransactionTypes', 'saleCash')
#        incomeOrCost: Enums.getValue('TransactionCustomerIncomeOrCost', 'saleCash')
#        receivable: false
#        amount: 0
#        description: ''
#
#    Session.set('transactionManagement', transactionManagement)
#
#
#
#  rendered: ->
#
#  destroyed: ->
#    Session.set('transactionShowHistory')
#    Session.set('transactionDetail')
#    Session.set('transactionOwner')
#
#
#  helpers:
#    isShowHistory: -> Session.get('transactionShowHistory')
#    transaction: -> Session.get('transactionManagement')
#
#    typeSelectOptions: scope.transactionTypeSelect
#    ownerSelectOptions: scope.transactionOwnerSelect
#    customerIncomeOrCostSelectOptions: scope.transactionOwnerIncomeOrCostSelect
#
#
#  events:
#    "click .createTransaction":  (event, template) ->
#      $payDescription = template.ui.$transactionDescription
#      $payAmount      = template.ui.$transactionAmount
#      transaction     = Session.get('transactionDetail')
#
#      if transaction.transactionType isnt undefined and
#        transaction.receivable isnt undefined and
#        transaction.owner and
#        transaction.amount > 0 and
#        transaction.description.length > 0
#
#          Meteor.call(
#            'createNewTransaction'
#            Enums.getValue('TransactionGroups', 'customer')
#            transaction.transactionType
#            transaction.receivable
#
#            transaction.owner
#            transaction.amount
#            transaction.description
#            (error, result) -> console.log error, result
#          )
#
#          $payDescription.val(''); $payAmount.val('')
#          transaction.amount = 0
#          Session.set('transactionDetail', transaction)